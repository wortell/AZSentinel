Write-Host "Executing Deploy.PS1"
if (
    $env:BuildSystem -eq 'GitHub Actions'
) {
    if ($env:BranchName -eq 'master' -and
        $env:NuGetApiKey -and
        $env:GitHubKey -and
        $env:CommitMessage -match '!Deploy'
    ) {
        $manifest = Import-PowerShellDataFile -Path "./$env:ProjectName/$env:ProjectName.psd1"
        $manifest.RequiredModules | ForEach-Object {
            if ([string]::IsNullOrEmpty($_)) {
                return
            }
            $ReqModuleName = ([Microsoft.PowerShell.Commands.ModuleSpecification]$_).Name
            $InstallModuleParams = @{Name = $ReqModuleName}
            if ($ReqModuleVersion = ([Microsoft.PowerShell.Commands.ModuleSpecification]$_).RequiredVersion) {
                $InstallModuleParams.Add('RequiredVersion', $ReqModuleVersion)
            }
            Install-Module @InstallModuleParams -Force
        }

        Deploy Module {
            By PSGalleryModule {
                FromSource $(Get-Item "./BuildOutput/$Env:ProjectName")
                To PSGallery
                WithOptions @{
                    ApiKey = $Env:NuGetApiKey
                }
            }
        }

        Write-Host "Creating GitHub release" -ForegroundColor Green
        $updatedManifest = Import-PowerShellDataFile ./BuildOutput/$env:ProjectName/$env:ProjectName.psd1

        $releaseData = @{
            tag_name = '{0}' -f $updatedManifest.ModuleVersion
            target_commitish = $env:GITHUB_SHA
            name = '{0}' -f $updatedManifest.ModuleVersion
            body = $updatedManifest.PrivateData.PSData.ReleaseNotes
            draft = $false
            prerelease = $false
        }

        $releaseParams = @{
            Uri = "https://api.github.com/repos/$env:GITHUB_REPOSITORY/releases?access_token=$env:GitHubKey"
            Method = 'POST'
            ContentType = 'application/json'
            Body = (ConvertTo-Json $releaseData -Compress)
            UseBasicParsing = $true
        }
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $newRelease = Invoke-RestMethod @releaseParams

        Compress-Archive -DestinationPath "./BuildOutput/$($env:ProjectName)_$($updatedManifest.ModuleVersion).zip" -Path ./BuildOutput/$env:ProjectName/*.*

        $uploadParams = @{
            Uri = ($newRelease.upload_url -replace '\{\?name.*\}', '?name=AzSentinel_') +
                $updatedManifest.ModuleVersion +
                '.zip&access_token=' +
                $env:GitHubKey
            Method = 'POST'
            ContentType = 'application/zip'
            InFile = "./BuildOutput/$($env:ProjectName)_$($updatedManifest.ModuleVersion).zip"
        }

        $null = Invoke-RestMethod @uploadParams
    } else {
        write-host "Did not comply with release conditions"
        Write-Host "BranchName: $env:BranchName"
        Write-Host "NuGetApiKey: $env:NuGetApiKey"
        Write-Host "GitHubKey: $env:GitHubKey"
        Write-Host "CommitMessage: $env:CommitMessage"
    }
} else {
    Write-Host "Not In Github Actions. Skipped"
}

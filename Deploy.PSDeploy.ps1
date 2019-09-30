param (
    [string] $ProjectName = "AzSentinel"
)


$manifest = Import-PowerShellDataFile -Path ".\$Env:ProjectName\$Env:ProjectName.psd1"
$manifest.RequiredModules | ForEach-Object {
    if ([string]::IsNullOrEmpty($_)) {
        return
    }
    $ReqModuleName = ([Microsoft.PowerShell.Commands.ModuleSpecification]$_).Name
    $InstallModuleParams = @{Name = $ReqModuleName}
    if ($ReqModuleVersion = ([Microsoft.PowerShell.Commands.ModuleSpecification]$_).RequiredVersion) {
        $InstallModuleParams.Add('RequiredVersion', $ReqModuleVersion)
    }
    #Install-Module @InstallModuleParams -Force
}

Deploy Module {
    By PSGalleryModule {
        FromSource $(Get-Item ".\BuildOutput\$ProjectName")
        To PSGallery
        WithOptions @{
            ApiKey = $env:NuGetApiKey
        }
    }
}


Write-Host "Creating GitHub release" -ForegroundColor Green
$updatedManifest = Import-PowerShellDataFile .\BuildOutput\$ProjectName\$ProjectName.psd1

# Package project
Compress-Archive -DestinationPath ".\BuildOutput\AzSentinel_$($updatedManifest.ModuleVersion).zip" -Path .\BuildOutput\$ProjectName\*.*

$releaseData = @{
    tag_name = '{0}' -f $updatedManifest.ModuleVersion
    target_commitish = 'master'
    name = '{0}' -f $updatedManifest.ModuleVersion
    body = $updatedManifest.PrivateData.PSData.ReleaseNotes
    draft = $false
    prerelease = $false
}
$releaseParams = @{
    Uri             = "https://api.github.com/repos/wortell/AzSentinel/releases?access_token=$env:GithubKey"
    Method          = 'POST'
    ContentType     = 'application/json'
    Body            = (ConvertTo-Json $releaseData -Compress)
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$newRelease = Invoke-RestMethod @releaseParams -UseBasicParsing:$true

$uploadParams = @{
    Uri = ($newRelease.upload_url -replace '\{\?name.*\}', '?name=AzSentinel_') +
        $updatedManifest.ModuleVersion +
        '.zip&access_token=' +
        $env:GitHubKey
    Method = 'POST'
    ContentType = 'application/zip'
    InFile = ".\BuildOutput\AzSentinel_$($updatedManifest.ModuleVersion).zip"
}

$null = Invoke-RestMethod @uploadParams

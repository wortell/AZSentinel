function Get-MergedModule {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $Name,
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.IO.DirectoryInfo] $SourceFolder,
        [Parameter(ValueFromPipelineByPropertyName)]
        [ScriptBlock] $Order = { }
    )
    begin {
        $usingList = [System.Collections.Generic.List[String]]::new()
        $requiresList = [System.Collections.Generic.List[String]]::new()
        $merge = [System.Text.StringBuilder]::new()
        $publicList = [System.Collections.Generic.List[String]]::new()
    }
    process {
        try {
            $null = $Order.Invoke()
        }
        catch {
            Write-Warning "YOUR CLASS ORDERING IS INVALID. USING DEFAULT ORDERING"
            $Order = { }
        }
        Write-Verbose -Message "Processing $Name"
        $FilePath = [System.IO.Path]::Combine($SourceFolder, $Name)
        Get-ChildItem -Path $FilePath -Filter *.ps1 -Recurse | Sort-Object $Order | ForEach-Object -Process {
            if ($Name -eq 'public') {
                $publicList.Add($_.BaseName)
            }
            $content = $_ | Get-Content | ForEach-Object {
                if ($_ -match '^using') {
                    $usingList.Add($_)
                }
                elseif ($_ -match '#requires') {
                    $requiresList.Add($_)
                }
                else {
                    $_.TrimEnd()
                }
            } | Out-String
            $null = $merge.AppendFormat('{0}{1}', $content.Trim(), "`n`n")
        }
    }
    end {
        $null = $merge.Insert(0, ($usingList | Sort-Object | Get-Unique | Out-String) + "`n")
        $null = $merge.Insert(0, ($requiresList | Sort-Object | Get-Unique | Out-String))
        if ($publicList.Count -ge 1) {
            $null = $merge.Append('Export-ModuleMember -Function @(')
            foreach ($p in ($publicList | Sort-Object)) {
                $null = $merge.Append("`n    '$p'")
            }
            $null = $merge.Append("`n)")
        }
        $merge.ToString()
    }
}

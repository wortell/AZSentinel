$enums = Get-ChildItem -Path $PSScriptRoot\enums\*.ps1 -ErrorAction SilentlyContinue | ForEach-Object -Process {
    Get-Content $_.FullName
}

if (Test-Path "$PSScriptRoot\Classes\classes.psd1") {
    $ClassLoadOrder = Import-PowerShellDataFile -Path "$PSScriptRoot\classes\classes.psd1" -ErrorAction SilentlyContinue
}

$classes = foreach ($class in $ClassLoadOrder.order) {
    $path = '{0}\classes\{1}.ps1' -f $PSScriptRoot, $class
    if (Test-Path $path) {
        Get-Content $path
    }
}

$public  = Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Exclude WIP* -ErrorAction SilentlyContinue | ForEach-Object -Process {
    Get-Content $_
    "Export-ModuleMember -Function $($_.Basename)"
}

$private = Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Exclude WIP* -ErrorAction SilentlyContinue | ForEach-Object -Process {
    Get-Content $_
}

$moduleContent = @'
$DSCPullServerConnections = [System.Collections.ArrayList]::new()
{0}
{1}
{2}
{3}
'@ -f ($enums -join "`n"), ($classes -join "`n"), ($private -join "`n"), ($public -join "`n")

$scriptBlock = [scriptblock]::Create($moduleContent)

New-Module -Name DSCPullServerAdmin -ScriptBlock $scriptBlock

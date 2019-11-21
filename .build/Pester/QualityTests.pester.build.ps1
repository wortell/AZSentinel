param (
    [string] $BuildOutput = (property BuildOutput 'BuildOutput'),

    [string] $ProjectName = 'AzSentinel',

    [string] $PesterOutputFormat = (property PesterOutputFormat 'NUnitXml'),

    [string] $RelativePathToQualityTests = (property RelativePathToQualityTests 'tests/QA'),

    [string] $PesterOutputSubFolder = (property PesterOutputSubFolder 'PesterOut')
)

# Synopsis: Making sure the Module meets some quality standard (help, tests)
task Quality_Tests {
    "`tProject Path     = $ProjectPath"
    "`tProject Name     = $ProjectName"
    "`tQuality Tests    = $RelativePathToQualityTests"

    $QualityTestPath = [io.DirectoryInfo][system.io.path]::Combine($ProjectPath, $ProjectName, $RelativePathToQualityTests)

    if (-not $QualityTestPath.Exists -and
        (   #Try a module structure where the
            ($QualityTestPath = [io.DirectoryInfo][system.io.path]::Combine($ProjectPath, $RelativePathToQualityTests)) -and
            -not $QualityTestPath.Exists
        )
    ) {
        Write-Warning ('Cannot Execute Quality tests, Path Not found {0}' -f $QualityTestPath)
        return
    }

    "`tQualityTest Path = $QualityTestPath"
    if (-not [io.path]::IsPathRooted($BuildOutput)) {
        $BuildOutput = Join-Path -Path $ProjectPath.FullName -ChildPath $BuildOutput
    }

    $PSVersion = 'PSv{0}.{1}' -f $PSVersionTable.PSVersion.Major, $PSVersionTable.PSVersion.Minor
    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $TestResultFileName = "QA_$PSVersion`_$TimeStamp.xml"
    $TestResultFile = [system.io.path]::Combine($BuildOutput,'testResults','QA',$PesterOutputFormat,$TestResultFileName)
    $TestResultFileParentFolder = Split-Path $TestResultFile -Parent
    $PesterOutFilePath = [system.io.path]::Combine($BuildOutput,'testResults','QA',$PesterOutputSubFolder,$TestResultFileName)
    $PesterOutParentFolder = Split-Path $PesterOutFilePath -Parent

    if (-not (Test-Path $PesterOutParentFolder)) {
        Write-Verbose "CREATING Pester Results Output Folder $PesterOutParentFolder"
        $null = New-Item -Path $PesterOutParentFolder -ItemType Directory -Force
    }

    if (-not (Test-Path $TestResultFileParentFolder)) {
        Write-Verbose "CREATING Test Results Output Folder $TestResultFileParentFolder"
        $null = New-Item -Path $TestResultFileParentFolder -ItemType Directory -Force
    }

    Push-Location -Path $QualityTestPath

    #Import-module -Name Pester -ErrorAction Stop
    $script:QualityTestResults = Invoke-Pester -ErrorAction Stop -OutputFormat NUnitXml -OutputFile $TestResultFile -PassThru
    $null = $script:QualityTestResults | Export-Clixml -Path $PesterOutFilePath -Force
    Pop-Location
}

# Synopsis: This task ensures the build job fails if the test aren't successful.
task Fail_Build_if_Quality_Tests_failed -If ($CodeCoverageThreshold -ne 0) {
    "Asserting that no Quality test failed"
    assert ($script:QualityTestResults.FailedCount -eq 0) ('Failed {0} Quality tests. Aborting Build' -f $script:QualityTestResults.FailedCount)
}

# Synopsis: Meta task that runs Quality Tests, and fails if they're not successful
task Pester_Quality_Tests_Stop_On_Fail Quality_Tests,Fail_Build_if_Quality_Tests_failed

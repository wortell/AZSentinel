param (
    [string] $BuildOutput = (property BuildOutput 'BuildOutput'),

    [bool] $TestFromBuildOutput = $true,

    [string] $ProjectName = 'AzSentinel',

    [string] $PesterOutputFormat = (property PesterOutputFormat 'NUnitXml'),

    [string] $PathToUnitTests = (property PathToUnitTests 'tests/Unit'),

    [string] $PesterOutputSubFolder = (property PesterOutputSubFolder 'PesterOut'),

    [ValidateRange(0, 100)]
    [int]$CodeCoverageThreshold = (property CodeCoverageThreshold 90)
)

# Synopsis: Execute the Pester Unit tests
task Run_Unit_Tests {
    "`tProject Path                    = $BuildRoot"
    "`tProject Name                    = $ProjectName"
    "`tUnit Tests                      = $PathToUnitTests"
    "`tResult Folder                   = $BuildOutput\Unit\"
    if ($TestFromBuildOutput) {
        "`tTesting against compiled Module = $BuildOutput\$ProjectName"
    } else {
        "`tTesting against Source Code     = $BuildOutput\$BuildRoot"
    }

    #Resolving the Unit Tests path based on 2 possible Path:
    #    BuildRoot\ProjectName\tests\Unit (my way, I like to ship tests with Modules)
    # or BuildRoot\tests\Unit (Warren's way: http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/)
    $UnitTestPath = [io.DirectoryInfo][system.io.path]::Combine($BuildRoot, $ProjectName, $PathToUnitTests)

    if (!$UnitTestPath.Exists -and
        (   #Try a module structure where the tests are outside of the Source directory
            ($UnitTestPath = [io.DirectoryInfo][system.io.path]::Combine($BuildRoot, $PathToUnitTests)) -and
            !$UnitTestPath.Exists
        )
    ) {
        Write-Warning ('Cannot Execute Unit tests, Path Not found {0}' -f $UnitTestPath)
        return
    }

    "`tUnitTest Path                   = $UnitTestPath"
    ''

    #Import-module Pester -ErrorAction Stop
    if (![io.path]::IsPathRooted($BuildOutput)) {
        $BuildOutput = Join-Path -Path $BuildRoot -ChildPath $BuildOutput
    }

    $PSVersion = 'PSv{0}.{1}' -f $PSVersionTable.PSVersion.Major, $PSVersionTable.PSVersion.Minor
    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $TestResultFileName = "Unit_$PSVersion`_$TimeStamp.xml"
    $TestResultFile = [system.io.path]::Combine($BuildOutput, 'testResults', 'unit', $PesterOutputFormat, $TestResultFileName)
    $TestResultFileParentFolder = Split-Path $TestResultFile -Parent
    $PesterOutFilePath = [system.io.path]::Combine($BuildOutput, 'testResults', 'unit', $PesterOutputSubFolder, $TestResultFileName)
    $PesterOutParentFolder = Split-Path $PesterOutFilePath -Parent
    $TestResultCodeCovFileName = "CodeCov_$PSVersion`_$TimeStamp.json"
    $TestResultCodeCovFile = [system.io.path]::Combine($BuildOutput, 'testResults', 'unit', 'codecov', $TestResultCodeCovFileName)
    $TestResultCodeCovFileParentFolder = Split-Path $TestResultCodeCovFile -Parent

    if (!(Test-Path $PesterOutParentFolder)) {
        Write-Verbose "CREATING Pester Results Output Folder $PesterOutParentFolder"
        $null = New-Item $PesterOutParentFolder -ItemType Directory -Force
    }

    if (!(Test-Path $TestResultFileParentFolder)) {
        Write-Verbose "CREATING Test Results Output Folder $TestResultFileParentFolder"
        $null = New-Item $TestResultFileParentFolder -ItemType Directory -Force
    }

    if (!(Test-Path $TestResultCodeCovFileParentFolder)) {
        Write-Verbose "CREATING Test Results Output Folder $TestResultCodeCovFileParentFolder"
        $null = New-Item $TestResultCodeCovFileParentFolder -ItemType Directory -Force
    }

    Push-Location $UnitTestPath
    if ($TestFromBuildOutput) {
        $ListOfTestedFile = Get-ChildItem -Recurse "$BuildOutput\$ProjectName" -include *.ps1, *.psm1 -Exclude *.tests.ps1
    } else {
        $ListOfTestedFile = Get-ChildItem | Foreach-Object {
            $fileName = $_.BaseName -replace '\.tests'
            "$BuildRoot\$ProjectName\*\$fileName.ps1"
        }
    }

    $ListOfTestedFile | ForEach-Object { Write-Verbose $_}
    "Number of tested files: $($ListOfTestedFile.Count)"
    $PesterParams = @{
        ErrorAction = 'Stop'
        OutputFormat = $PesterOutputFormat
        OutputFile = $TestResultFile
        CodeCoverage = $ListOfTestedFile
        PassThru = $true
    }
    #Import-module Pester -ErrorAction Stop
    if ($TestFromBuildOutput) {
        Import-Module -Force ("$BuildOutput\$ProjectName" -replace '\\$')
    } else {
        Import-Module -Force ("$BuildRoot\$ProjectName" -replace '\\$')
    }

    $script:UnitTestResults = Invoke-Pester @PesterParams
    $null = $script:UnitTestResults | Export-Clixml -Path $PesterOutFilePath -Force

    # borrowed codecov json conversion from https://github.com/PowerShell/DscResource.Tests/blob/dev/DscResource.CodeCoverage/CodeCovIo.psm1
    function Add-UniqueFileLineToTable {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory)]
            [HashTable] $FileLine,

            [Parameter(Mandatory)]
            [Object] $Command,

            [Parameter(Mandatory)]
            [String] $TableName
        )

        # Populate the sub-table
        foreach ($command in $Command) {

            $file = $command.File
            $fileKey = $file.replace('\','/').TrimStart('/')
            if ($null -eq $fileKey) {
                Write-Warning -Message "Unexpected error filekey was null"
                continue
            }
            elseif ($fileKey.Count -ne 1) {
                Write-Warning -Message "Unexpected error, more than one git file matched file ($file): $($fileKey -join ', ')"
                continue
            }

            $fileKey = $fileKey | Select-Object -First 1

            if (!$FileLine.ContainsKey($fileKey)) {
                $FileLine.add($fileKey, @{ $TableName = @{}})
            }

            if (!$FileLine.$fileKey.ContainsKey($TableName)) {
                $FileLine.$fileKey.Add($TableName,@{})
            }

            $lines = $FileLine.($fileKey).$TableName
            $lineKey = $($command.line)
            if (!$lines.ContainsKey($lineKey)) {
                $lines.Add($lineKey,1)
            } else {
                $lines.$lineKey ++
            }
        }
    }

    function Export-CodeCovIoJson {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [object] $CodeCoverage,

            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string] $Path
        )

        # Get a list of all unique files
        $files = @()
        foreach ($file in ($CodeCoverage.MissedCommands | Select-Object -ExpandProperty File -Unique)) {
            if ($files -notcontains $file) {
                $files += $file
            }
        }

        foreach ($file in ($CodeCoverage.HitCommands | Select-Object -ExpandProperty File -Unique)) {
            if ($files -notcontains $file) {
                $files += $file
            }
        }

        $FileLine  = @{}

        $addUniqueFileLineParams= @{
            FileLine = $FileLine
        }

        Add-UniqueFileLineToTable -Command $CodeCoverage.MissedCommands -TableName 'misses' @addUniqueFileLineParams
        Add-UniqueFileLineToTable -Command $CodeCoverage.HitCommands -TableName 'hits' @addUniqueFileLineParams

        $resultLineData = @{}
        $resultMessages = @{}
        $result         = @{
            coverage = $resultLineData
            messages = $resultMessages
        }

        foreach ($file in $FileLine.Keys) {
            $hit     = 0
            $partial = 0
            $missed  = 0

            $hits = @{}
            if ($FileLine.$file.ContainsKey('hits')) {
                $hits = $FileLine.$file.hits
            }

            $misses = @{}
            if ($FileLine.$file.ContainsKey('misses')) {
                $misses = $FileLine.$file.misses
            }

            $max = $hits.Keys | Sort-Object -Descending | Select-Object -First 1
            $maxMissLine = $misses.Keys | Sort-Object -Descending | Select-Object -First 1

            if ($maxMissLine -gt $max) {
                $max = $maxMissLine
            }

            $lineData = @()
            $messages = @{}

            for ($lineNumber = 0; $lineNumber -le $max; $lineNumber++) {
                $hitInfo = $null
                $missInfo = $null
                switch ($true) {
                    # Hit
                    ($hits.ContainsKey($lineNumber) -and ! $misses.ContainsKey($lineNumber)) {
                        Write-Verbose -Message "Got code coverage hit at $lineNumber"
                        $lineData += "$($hits.$lineNumber)"
                    }

                    # Miss
                    ($misses.ContainsKey($lineNumber) -and ! $hits.ContainsKey($lineNumber)) {
                        Write-Verbose -Message "Got code coverage miss at $lineNumber"
                        $lineData += '0'
                    }

                    # Partial Hit
                    ($misses.ContainsKey($lineNumber) -and $hits.ContainsKey($lineNumber)) {
                        Write-Verbose -Message "Got code coverage partial at $lineNumber"

                        $missInfo = $misses.$lineNumber
                        $hitInfo = $hits.$lineNumber
                        $lineData += "$hitInfo/$($hitInfo+$missInfo)"
                    }

                    # Non-Code Line
                    (!$misses.ContainsKey($lineNumber) -and !$hits.ContainsKey($lineNumber)) {
                        Write-Verbose -Message "Got non-code at $lineNumber"
                        $lineData += '!null!'
                    }

                    default {
                        throw "Unexpected error occured generating codeCov.io report for $file at line $lineNumber with hits: $($hits.ContainsKey($lineNumber)) and misses: $($misses.ContainsKey($lineNumber))"
                    }
                }
            }

            $resultLineData.Add($file,$lineData)
            $resultMessages.add($file,$messages)
        }

        $json = $result | ConvertTo-Json
        $json = $json.Replace('"!null!"','null')

        $json | Out-File -Encoding ascii -LiteralPath $Path -Force
        return $Path
    }

    Export-CodeCovIoJson -CodeCoverage $script:UnitTestResults.CodeCoverage -Path $TestResultCodeCovFile

    Pop-Location
}

# Synopsis: If the Unit test failed, fail the build (unless Threshold is set to 0)
task Fail_Build_if_Unit_Test_Failed -If ($CodeCoverageThreshold -ne 0) {
    assert ($script:UnitTestResults.FailedCount -eq 0) ('Failed {0} Unit tests. Aborting Build' -f $script:UnitTestResults.FailedCount)
}

# Synopsis: If the Code coverage is under the defined threshold, fail the build
task Fail_if_Last_Code_Coverage_is_Under_Threshold {
    "`tProject Path     = $BuildRoot"
    "`tProject Name     = $ProjectName"
    "`tUnit Tests       = $PathToUnitTests"
    "`tResult Folder    = $BuildOutput\Unit\"
    "`tMin Coverage     = $CodeCoverageThreshold %"
    ''

    if (![io.path]::IsPathRooted($BuildOutput)) {
        $BuildOutput = Join-Path -Path $BuildRoot -ChildPath $BuildOutput
    }

    $TestResultFileName = "Unit_*.xml"
    $PesterOutPath = [system.io.path]::Combine($BuildOutput, 'testResults', 'unit', $PesterOutputSubFolder, $TestResultFileName)
    if (-Not (Test-Path $PesterOutPath)) {
        if ( $CodeCoverageThreshold -eq 0 ) {
            Write-Host "Code Coverage SUCCESS with value of 0%. No Pester output found." -ForegroundColor Magenta
            return
        } else {
            Throw "No command were tested. Threshold of $CodeCoverageThreshold % not met"
        }
    }
    $PesterOutPath
    $PesterOutFile = Get-ChildItem -Path $PesterOutPath |  Sort-Object -Descending | Select-Object -first 1
    $PesterObject = Import-Clixml -Path $PesterOutFile.FullName
    if ($PesterObject.CodeCoverage.NumberOfCommandsAnalyzed) {
        $coverage = $PesterObject.CodeCoverage.NumberOfCommandsExecuted / $PesterObject.CodeCoverage.NumberOfCommandsAnalyzed
        if ($coverage -lt $CodeCoverageThreshold / 100) {
            throw "The Code Coverage FAILURE: ($($Coverage*100) %) is under the threshold of $CodeCoverageThreshold %."
        } else {
            Write-Host "Code Coverage SUCCESS with value of $($coverage*100) %" -ForegroundColor Green
        }
    }
}

# Synopsis: Task to Run the unit tests and fail build if failed or if the code coverage is under threshold
task Pester_Unit_Tests_Stop_On_Fail Run_Unit_Tests,
Fail_Build_if_Unit_Test_Failed,
Fail_if_Last_Code_Coverage_is_Under_Threshold

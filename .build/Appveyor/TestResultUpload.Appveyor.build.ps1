param (
    [string] $BuildOutput = (property BuildOutput 'BuildOutput'),

    [string] $ProjectName = (property ProjectName (Split-Path -Leaf $BuildRoot) ),

    [string] $PesterOutputFormat = (property PesterOutputFormat 'NUnitXml'),

    [string] $APPVEYOR_JOB_ID = $(try {property APPVEYOR_JOB_ID} catch {})
)

# Synopsis: Uploading Unit Test results to AppVeyor
task Upload_Unit_Test_Results_To_AppVeyor -If {(property BuildSystem 'unknown') -eq 'AppVeyor'} {

    if (![io.path]::IsPathRooted($BuildOutput)) {
        $BuildOutput = Join-Path -Path $BuildRoot -ChildPath $BuildOutput
    }

    $TestOutputPath  = [system.io.path]::Combine($BuildOutput,'testResults','unit',$PesterOutputFormat)
    $TestResultFiles = Get-ChildItem -Path $TestOutputPath -Filter *.xml
    Write-Build Green "  Uploading test results [$($TestResultFiles.Name -join ', ')] to Appveyor"
    $TestResultFiles | Add-TestResultToAppveyor
    Write-Build Green "  Upload Complete"
}

# Synopsis: Uploading Unit Test results to CodeCov
task Upload_Unit_Test_Results_To_CodeCov -If {(property BuildSystem 'unknown') -eq 'AppVeyor'} {
    if (![io.path]::IsPathRooted($BuildOutput)) {
        $BuildOutput = Join-Path -Path $BuildRoot -ChildPath $BuildOutput
    }

    $TestOutputPath  = [system.io.path]::Combine($BuildOutput,'testResults','unit', 'codecov')
    $TestResultFiles = Get-ChildItem -Path $TestOutputPath -Filter *.json

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/codecov/codecov-exe/releases/download/1.1.0/Codecov.zip' -OutFile .\Codecov.zip
    $ProgressPreference = 'Continue'
    Unblock-File -Path .\Codecov.zip
    Expand-Archive -Path .\Codecov.zip -DestinationPath .\codecov

    Write-Build Green "  Uploading test results [$($TestResultFiles.Name -join ', ')] to CodeCov"

    .\codecov\codecov.exe -f $TestResultFiles.FullName --root $BuildRoot
}

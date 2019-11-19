[cmdletBinding()]
Param (
    [Parameter(Position = 0)]
    $Tasks,

    [switch] $ResolveDependency,

    [string] $BuildOutput = 'BuildOutput',

    [switch] $ForceEnvironmentVariables = [switch]$true,

    $MergeList = @('enum*', [PSCustomObject]@{Name = 'class*'; order = { (Import-PowerShellDataFile -EA 0 .\*\Classes\classes.psd1).order.indexOf($_.BaseName) } }, 'priv*', 'pub*'),

    $TaskHeader = {
        param($Path)
        ''
        '=' * 79
        Write-Build Cyan "`t`t`t$($Task.Name.replace('_',' ').ToUpper())"
        Write-Build DarkGray  "$(Get-BuildSynopsis $Task)"
        '-' * 79
        Write-Build DarkGray "  $Path"
        Write-Build DarkGray "  $($Task.InvocationInfo.ScriptName):$($Task.InvocationInfo.ScriptLineNumber)"
        ''
    },

    $CodeCoverageThreshold = 0
)

Process {
    if ($MyInvocation.ScriptName -notlike '*Invoke-Build.ps1') {
        if ($PSboundParameters.ContainsKey('ResolveDependency')) {
            Write-Verbose "Dependency already resolved. Handing over to InvokeBuild."
            $null = $PSboundParameters.Remove('ResolveDependency')
        }
        Invoke-Build $Tasks $MyInvocation.MyCommand.Path @PSBoundParameters
        return
    }

    # Loading Build Tasks defined in the .build/ folder
    Get-ChildItem -Path "$PSScriptRoot/.build/" -Recurse -Include *.ps1 -Verbose |
    Foreach-Object {
        "Importing file $($_.BaseName)" | Write-Verbose
        . $_.FullName
    }

    # Defining the task header for this Build Job
    if ($TaskHeader) { Set-BuildHeader $TaskHeader }

    # Defining the Default task 'workflow' when invoked without -tasks parameter
    task .  Clean,
    Set_Build_Environment_Variables,
    Pester_Quality_Tests_Stop_On_Fail,
    Copy_Source_To_Module_BuildOutput,
    Merge_Source_Files_To_PSM1,
    Clean_Folders_from_Build_Output,
    Update_Module_Manifest,
    Run_Unit_Tests,
    Fail_Build_if_Unit_Test_Failed,
    Fail_if_Last_Code_Coverage_is_Under_Threshold,
    Deploy_with_PSDeploy

    # Define a testAll tasks for interactive testing
    task testAll UnitTests, IntegrationTests, QualityTestsStopOnFail

    # Define a dummy task when you don't want any task executed (e.g. Only load PSModulePath)
    task Noop { }
}


begin {
    function Resolve-Dependency {
        [CmdletBinding()]
        param()
        if (!(Get-Module -Listavailable PSDepend)) {
            Write-verbose "BootStrapping PSDepend"
            "Parameter $BuildOutput" | Write-verbose
            $InstallPSDependParams = @{
                Name = 'PSDepend'
                AllowClobber = $true
                Confirm = $false
                Force = $true
                Scope = 'CurrentUser'
            }
            if ($PSBoundParameters.ContainsKey('verbose')) { $InstallPSDependParams.add('verbose', $verbose) }
            Install-Module @InstallPSDependParams
        }

        $PSDependParams = @{
            Force = $true
            Path = "$PSScriptRoot/PSDepend.build.psd1"
            Install = $true
        }
        if ($PSBoundParameters.ContainsKey('verbose')) { $PSDependParams.add('verbose', $verbose) }
        Invoke-PSDepend @PSDependParams
        Write-Verbose "Project Bootstrapped, returning to Invoke-Build"
    }

    if (![io.path]::IsPathRooted($BuildOutput)) {
        $BuildOutput = Join-Path -Path $PSScriptRoot -ChildPath $BuildOutput
    }

    $pathSeparator =  [System.IO.Path]::PathSeparator

    if (($Env:PSModulePath -split $pathSeparator) -notcontains (Join-Path $BuildOutput 'modules') ) {
        $Env:PSModulePath = (Join-Path $BuildOutput 'modules') + $pathSeparator + $Env:PSModulePath
    }


    if ($ResolveDependency) {
        Write-Host "Resolving Dependencies... [this can take a moment]"
        $Params = @{ }
        if ($PSboundParameters.ContainsKey('verbose')) {
            $Params.Add('verbose', $verbose)
        }
        Resolve-Dependency @Params
    }
}

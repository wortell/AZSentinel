<#
    FROM: https://raw.githubusercontent.com/DuPSUG/DuPSUG15/master/PesterVsSloppiness_BartoszBielawski/Tests/Test-ModuleFunction.Tests.ps1
#>

using namespace System.Management.Automation
using namespace System.Management.Automation.Language
param (
    [String]$ModuleName = '*',
    [String]$FunctionName = '*'
)

# PSScriptAnalyzer rules included in module test.
$analyzerRules = @(
    'PSUseDeclaredVarsMoreThanAssigments'
    'PSShouldProcess'
    'PSUsePSCredentialType'
    'PSUseSingularNouns'
    'PSUseOutputTypeCorrectly'
    'PSUseApprovedVerbs'
)

foreach ($file in Get-ChildItem -Path "$PSScriptRoot\..\$ModuleName\$ModuleName.psd1") {
    if (
        $file.Basename -ne $file.Directory.Name -or
        -not (Get-ChildItem -Path "$($file.DirectoryName)\$FunctionName.ps1")
    ) {
        Write-Host "File $($file.Name) doesn't contain any functions or it's not a module manifest"
        continue
    }

    $testedModuleName = $file.Basename
    Describe "Testing module $testedModuleName" {
        It 'Can be imported without errors' {
            { Import-Module $file.FullName -ErrorAction Stop -Force } | Should -Not -Throw
        }
    }

    foreach (
        $function in (
            Get-Command -Module $testedModuleName -CommandType Function |
            Where-Object Name -Like $FunctionName
        )
    ) {
        $testedFunctionName = $function.Name
        Describe "Testing function $testedFunctionName defined in module $testedModuleName" {
            $ast = [Parser]::ParseFile(
                "$($file.Directory.FullName)\$testedFunctionName.ps1",
                [ref]$null,
                [ref]$null
            )

            $functions = $ast.FindAll(
                {
                    param (
                        [Ast]$astItem
                    )
                    $astItem -is [FunctionDefinitionAst]
                },
                $true
            )

            $parameters = $ast.FindAll(
                {
                    param (
                        [Ast]$astItem
                    )
                    $astItem -is [ParameterAst]
                },
                $true
            )

            $variables = $ast.FindAll(
                {
                    param (
                        [Ast]$astItem
                    )
                    $astItem -is [VariableExpressionAst]
                },
                $true
            )

            $functionHelp = Get-Help $testedFunctionName
            $cmdProperties = Get-Command $testedFunctionName

            It 'Has help description' {
                $functionHelp.Description | Should -Not -BeNullOrEmpty
            }

            $functionHelp.parameters.parameter |
            Where-Object { $_.Name -and $_.Name -notin 'WhatIf', 'Confirm' } |
            ForEach-Object {
                It "Help description for parameter $($_.Name) is set" {
                    $_.Description | Should -Not -BeNullOrEmpty
                }
            }

            It 'Has help examples' {
                $functionHelp.Examples | Should -Not -BeNullOrEmpty
            }

            It 'Uses CmdletBinding' {
                $cmdProperties.CmdletBinding | Should -BeTrue
            }

            #If ($cmdProperties.Verb -in 'New', 'Remove', 'Set', 'Stop') {
            If ($cmdProperties.Verb -in 'New', 'Remove', 'Stop') {
                It 'Should support WhatIf' {
                    [bool]$cmdProperties.Parameters['WhatIf'] | Should -BeTrue
                }
            }

            # Test the parameters defined in the function, parameters from subfunctions are not evaluated.
            $functionParameters = (
                $functions | Where-Object { $_.Name -eq $testedFunctionName }
            ).Body.FindAll(
                {
                    param (
                        [Ast]$astItem
                    )
                    $astItem -is [ParameterAst]
                },
                $false
            )

            $parameterNames = foreach ($parameter in $functionParameters) {
                ($parameterName = $parameter.Name.VariablePath.UserPath)
                if (
                    -not (
                        $variables | Where-Object {
                            $_.VariablePath.UserPath -eq 'PSBoundParameters'
                        }
                    ).Splatted
                ) {
                    It "Uses parameter $parameterName in code" {
                        (
                            (
                                (
                                    $variables.VariablePath.UserPath | Where-Object { $_ -eq $parameterName }
                                ) | Measure-Object
                            ).Count -ge 2
                        ) -or
                        $variables.VariablePath.UserPath -contains 'PSBoundParameters' | Should -BeTrue
                    }
                }

                It "Has a datatype assigned to parameter $parameterName" {
                    $parameter.Attributes | Where-Object {
                        $_.psobject.properties.name -notcontains 'NamedArguments'
                    } | Should -Not -BeNullOrEmpty
                }

                It "Uses PascalCase for parameter $parameterName" {
                    $parameterName | Should -MatchExactly '^[A-Z].*'
                }
            }

            foreach ($variable in $variables) {
                $variableName = $variable.VariablePath.UserPath
                if ($variableName -in $parameterNames) {
                    continue
                }
                It "Uses camelCase for variable $variableName" {
                    $variableName | Should -MatchExactly '^[a-z_PSScriptRoot]'
                    #$variableName | Should -MatchExactly '^([a-z][0-9]?)+(([A-Z]{1}([a-z]|[0-9]){1}([a-z]|[0-9]?)+)?)+'
                }
            }

            It "Should pass analyzer rules" {
                $testResults = Invoke-ScriptAnalyzer -Path "$($file.Directory.FullName)\$testedFunctionName.ps1" -IncludeRule $analyzerRules
                if ($testResults) {
                    $message = "Found {0} issues:`n{1}" -f @(
                        $testResults.Count
                        ($testResults.Foreach{
                                "Script: $($_.ScriptPath) Line: $($_.Line) - $($_.Message)"
                            } -join "`n")
                    )
                    $errorRecord = [ErrorRecord]::new(
                        [Exception]::new($message),
                        'PesterAssertionFailed',
                        [ErrorCategory]::InvalidResult,
                        $MyInvocation
                    )
                    throw $errorRecord
                }
            }
        }

        foreach ($function in (
                Get-Command -Module $file.Basename -CommandType Function | Where-Object Name -Like $FunctionName
            )) {
            Context "Testing function $($function.Name) defined in module $($file.Basename)" {
                It 'Uses file dot-sourcing ' {
                    $function.ScriptBlock.File | Should -Not -BeNullOrEmpty
                }

                It 'File where function is defined has correct BaseName' {
                    (Get-Item $function.ScriptBlock.File).BaseName | Should -Be $function.Name
                }
            }
        }
    }
}

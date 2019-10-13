<#
    https://raw.githubusercontent.com/DuPSUG/DuPSUG15/master/PesterVsSloppiness_BartoszBielawski/Tests/Test-ModuleManifest.Tests.ps1
#>

using namespace System.Management.Automation.Language

param (
    $ModuleName = 'AzSentinel'
)


foreach ($manifest in Get-ChildItem $PSScriptRoot\..\$ModuleName\$ModuleName.psd1) {
    if ($manifest.Basename -ne $manifest.Directory.Name) {
        # Looks like this psd1 is not really a module manifest...
        continue
    }
    Describe "Testing Module Manifest Metadata: $($manifest.BaseName)" {
        It 'Has proper manifest' {
            { Test-ModuleManifest -Path $manifest.FullName } | Should -Not -Throw
        }
        Context "Testing properties within module manifest $($manifest.BaseName)" {
            $moduleInfo = Test-ModuleManifest -Path $manifest.FullName -ErrorAction SilentlyContinue
            It 'Has author defined' {
                $moduleInfo.Author | Should -Not -BeNullOrEmpty
            }
            It 'Has description defined' {
                $moduleInfo.Description | Should -Not -BeNullOrEmpty
            }
            It 'Has tags in PSData' {
                $moduleInfo.PrivateData.PSData.Tags | Should -Not -BeNullOrEmpty
            }
            It 'Has Project URI' {
                $moduleInfo.PrivateData.PSData.ProjectUri | Should -Not -BeNullOrEmpty
            }
            It 'Project URI Points to github' {
                $moduleInfo.PrivateData.PSData.ProjectUri | Should -Match ([regex]::Escape('https://github.com'))
            }
            It 'Has a version with 3' {
                $moduleInfo.Version.ToString().Split('.') | Should -HaveCount 3
            }

            It 'Has Company configured' {
                $moduleInfo.CompanyName | Should -Not -BeNullOrEmpty
            }

            if ($moduleInfo.RootModule) {
                $modulePath = $manifest.FullName | Split-Path -Parent
                $fullPath = Join-Path -ChildPath $moduleInfo.RootModule -Path $modulePath

                $ast = [Parser]::ParseFile(
                    $fullPath,
                    [ref]$null,
                    [ref]$null
                )

                $astFunctionSearch = {
                    param (
                        $astItem
                    )
                    $astItem -is [FunctionDefinitionAst] -and
                    #$astItem.Name -like '*-OP*'
                    $astItem.Name -like '*'
                }

                $functionNames = $ast.FindAll(
                    $astFunctionSearch,
                    $false
                ).Name

                if (-not $functionNames) {
                    # Using 'dot-source' model, lets verify it...
                    $dotSourcing = $ast.FindAll(
                        {
                            param (
                                $astItem
                            )
                            $astItem -is [CommandAst] -and
                            $astItem.InvocationOperator -eq [TokenKind]::Dot
                        },
                        $false
                    )

                    if ($dotSourcing) {
                        # For now - I assume 'our' model - dot-source all ps1's in current folder...
                        $functionNames = foreach ($script in Get-ChildItem -Path "$modulePath\*.ps1" -Exclude '*.classes.ps1') {
                            $scriptAst = [Parser]::ParseFile(
                                $script.FullName,
                                [ref]$null,
                                [ref]$null
                            )
                            $functions = $scriptAst.FindAll(
                                $astFunctionSearch,
                                $false
                            )

                            $functions.Name

                            # Quick test on ps1's to verify we are not doing anything odd...
                            It "Should contain just one function definition in $($script.Name)" {
                                $functions | Should -HaveCount 1
                            }

                            It "Function name should be same as file name $($script.Basename)" {
                                $functions.Name | Should -Be $script.Basename
                            }

                            It "Function defined in $($script.Name) should not be called" {
                                $scriptAst.FindAll(
                                    {
                                        param (
                                            $astItem
                                        )
                                        $astItem -is [CommandAst] -and
                                        $astItem.CommandElements[0].Value -eq $script.Basename
                                    },
                                    $false
                                ) | Should -BeNullOrEmpty
                            }

                            $classes = $scriptAst.FindAll(
                                {
                                    param (
                                        $astItem
                                    )
                                    $astItem -is [TypeDefinitionAst]
                                },
                                $false
                            )

                            It "Classes and enums should not be defined in function file $($Script.Name), use $($manifest.Basename).classes.ps1 instead" {
                                $classes.Name -join ', ' | Should -BeNullOrEmpty
                            }
                        }
                    }
                }
                $exportedFunctions = $moduleInfo.ExportedFunctions.Keys

                foreach ($name in $functionNames) {
                    It "Exports exports function $name in manifest" {
                        $exportedFunctions | Should -Contain $name
                    }
                }

                It "Doesn't use wildcards in exportedFunctions" {
                    $exportedFunctions.Where{
                        [WildcardPattern]::ContainsWildcardCharacters($_)
                    } | Should -BeNullOrEmpty
                }
            }
        }
    }
}

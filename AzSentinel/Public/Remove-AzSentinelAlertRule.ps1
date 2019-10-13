#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -module @{ModuleNAme = 'powershell-yaml'; ModuleVersion = '0.4.0'}
#requires -version 6.0

using module Az.Accounts

function Remove-AzSentinelAlertRule {
    <#
    .SYNOPSIS
    Remove Azure Sentinal Alert Rules
    .DESCRIPTION
    With this function you can remove Azure Sentinal Alert rules from Powershell, if you don't provide andy Rule name all rules will be removed
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER WorkspaceName
    Enter the Workspace name
    .PARAMETER RuleName
    Enter the name of the rule that you wnat to remove
    .EXAMPLE
    Remove-AzSentinelAlertRule -WorkspaceName "" -RuleName ""
    In this example the defined rule will be removed from Azure Sentinel
    .EXAMPLE
    Remove-AzSentinelAlertRule -WorkspaceName "" -RuleName "","", ""
    In this example you can define multiple rules that will be removed
    .EXAMPLE
    Remove-AzSentinelAlertRule -WorkspaceName ""
    In this example no rule is specified, all rules will be removed one by one. For each rule you need to confirm the action
    #>

    [cmdletbinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $false,
            ParameterSetName = "Sub")]
        [ValidateNotNullOrEmpty()]
        [string] $SubscriptionId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $false,
            ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string[]]$RuleName
    )

    begin {
        precheck
    }

    process {
        switch ($PsCmdlet.ParameterSetName) {
            Sub {
                $arguments = @{
                    WorkspaceName  = $WorkspaceName
                    SubscriptionId = $SubscriptionId
                }
            }
            default {
                $arguments = @{
                    WorkspaceName = $WorkspaceName
                }
            }
        }
        Get-LogAnalyticWorkspace @arguments

        if ($RuleName) {
            # remove defined rules
            foreach ($rule in $RuleName) {
                $item = Get-AzSentinelHuntingRule @arguments -RuleName $rule -WarningAction SilentlyContinue
                if ($item) {
                    $uri = "$script:baseUri/savedSearches/$($item.name)?api-version=2017-04-26-preview"

                    if ($PSCmdlet.ShouldProcess("Do you want to remove: $rule")) {
                        Write-Output $item
                        $result = Invoke-WebRequest -Uri $uri -Method DELETE -Headers $script:authHeader
                        Write-Output "Successfully removed rule: $($rule) with status: $($result.StatusDescription)"
                    }
                    else {
                        Write-Output "No change have been made for rule: $rule"
                    }
                }
                else {
                    Write-Warning "$rule not found in $WorkspaceName"
                }
            }
        }
        else {
            Write-Warning "No Rule selected, All rules will be removed one by one!"
            Get-AzSentinelHuntingRule @arguments | ForEach-Object {
                $uri = "$script:baseUri/savedSearches/$($_.name)?api-version=2017-04-26-preview"
                if ($PSCmdlet.ShouldProcess("Do you want to remove: $($_.displayName)")) {
                    $result = Invoke-WebRequest -Uri $uri -Method DELETE -Headers $script:authHeader
                    Write-Output "Successfully removed rule: $($_.displayName) with status: $($result.StatusDescription)"
                }
                else {
                    Write-Output "No change have been made for rule: $($_.displayName)"
                }
            }
        }
    }
}

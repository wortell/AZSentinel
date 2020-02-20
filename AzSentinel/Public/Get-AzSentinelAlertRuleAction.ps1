#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Get-AzSentinelAlertRuleAction {
    <#
      .SYNOPSIS
      Get Azure Sentinel Alert rule Action
      .DESCRIPTION
      This function can be used to see if an action is attached to the alert rule, if so then the configuration will be returned
      .PARAMETER SubscriptionId
      Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
      .PARAMETER WorkspaceName
      Enter the Workspace name
      .PARAMETER RuleName
      Enter the name of the Alert rule
      .PARAMETER RuleId
      Enter the Rule Id
      .EXAMPLE
      Get-AzSentinelAlertRuleAction -WorkspaceName "pkm02" -RuleName "testrule01"
      This example will get the Workspace ands return the full data object
      .NOTES
      NAME: Get-AzSentinelAlertRuleAction
    #>
    param (
        [Parameter(Mandatory = $false,
            ParameterSetName = "Sub")]
        [ValidateNotNullOrEmpty()]
        [string] $SubscriptionId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $WorkspaceName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$RuleName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$RuleId
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

        if ($RuleName) {
            $alertId = (Get-AzSentinelAlertRule @arguments -RuleName $RuleName).name
        }
        elseif ($RuleId) {
            $alertId = $RuleId
        }
        else {
            Write-Error "No Alert Name or ID is provided" -ErrorAction Continue
        }

        if ($alertId) {
            $uri = "$($Script:baseUri)/providers/Microsoft.SecurityInsights/alertRules/$($alertId)/actions?api-version=2019-01-01-preview"
            try {
                $return = (Invoke-RestMethod -Uri $uri -Method Get -Headers $script:authHeader).value
                return $return
            }
            catch {
                $return = $_.Exception.Message
                return $return
            }
        }
        else {
            $return = "No Alert found with provided: $($alertId)"
            return $return
        }
    }
}

#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Remove-AzSentinelAlertRuleAction {
    <#
      .SYNOPSIS
      Remove Azure Sentinel Alert rule Action
      .DESCRIPTION
      This function can be used to see if an action is attached to the alert rule, if so then the configuration will be returned
      .PARAMETER SubscriptionId
      Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
      .PARAMETER WorkspaceName
      Enter the Workspace name
      .PARAMETER RuleName
      Enter the name of the Alert rule
      .PARAMETER RuleId
      Enter the Alert Rule ID that you want to configure
      .EXAMPLE
      Remove-AzSentinelAlertRuleAction -WorkspaceName "" -RuleName "AlertRule01"
      This example will get the Workspace ands return the full data object
      .NOTES
      NAME: Remove-AzSentinelAlertRuleAction
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
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
            $result = Get-AzSentinelAlertRuleAction @arguments -RuleName $RuleName
        }
        elseif ($RuleId) {
            $result = Get-AzSentinelAlertRuleAction @arguments -RuleId $RuleId
        }
        else {
            Write-Error "No Alert Name or ID is provided"
        }

        if ($result) {
            $uri = "$($Script:baseUri)/providers/Microsoft.SecurityInsights/alertRules/$($result.id.split('asicustomalertsv3_')[-1])?api-version=2019-01-01-preview"
            Write-Verbose $uri

            if ($PSCmdlet.ShouldProcess("Do you want to remove Alert Rule action for rule: $($RuleName)")) {
                try {
                    $return = Invoke-WebRequest -Uri $uri -Method DELETE -Headers $script:authHeader
                    Write-Verbose $return
                    Write-Verbose "Rule action $($result.properties.logicAppResourceId.Split('/')[-1]) removed for rule $($RuleName) with status: $($return.StatusCode)"
                    return $return.StatusCode
                }
                catch {
                    Write-Verbose $_
                    return $_.Exception.Message
                }
            }
        }
        else {
            Write-Output "No Alert Action found for Rule: $($RuleName)"
        }
    }
}

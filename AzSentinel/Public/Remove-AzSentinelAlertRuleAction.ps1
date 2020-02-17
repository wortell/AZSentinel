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
      .EXAMPLE
      Remove-AzSentinelAlertRuleAction -WorkspaceName "pkm02" -RuleName "testrule01"
      This example will get the Workspace ands return the full data object
      .NOTES
      NAME: Remove-AzSentinelAlertRuleAction
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
        [string]$RuleName
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

        $result = Get-AzSentinelAlertRuleAction @arguments -RuleName $RuleName

        if ($result) {
            Write-Host
            $uri = "$($Script:baseUri)/providers/Microsoft.SecurityInsights/alertRules/$($result.id.split('asicustomalertsv3_')[-1])?api-version=2019-01-01-preview"
            Write-Host $uri
            try {
                $return = Invoke-WebRequest -Uri $uri -Method DELETE -Headers $script:authHeader

                if ($return.StatusCode -eq 200) {
                    return "Rule action $($result.properties.logicAppResourceId.Split('/')[-1]) removed for rule $($RuleName) with status: $($return.StatusCode)"
                }
                else {
                    Write-Verbose $_
                    return "Failed to remove rule action $($result.properties.logicAppResourceId.Split('/')[-1]) for rule $($RuleName) with errorcode: $($return.StatusCode)"
                }
            }
            catch {
                $return = $_.Exception.Message
                return $return
            }
        }
        else {
            return "No Alert Action found for Rule: $($RuleName)"
        }
    }
}

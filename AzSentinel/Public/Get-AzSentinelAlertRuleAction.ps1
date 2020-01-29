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
    .EXAMPLE
    Get-AzSentinelAlertRuleAction -WorkspaceName "" -RuleName ""
    This example will get the Workspace ands return the full data object
    .NOTES
    NAME: Get-AzSentinelAlertRuleAction
    Get-AzSentinelAlertRuleAction -WorkspaceName "pkm02" -RuleName "testrule01"
  #>
  param (
    [Parameter(Mandatory = $false,
      ParameterSetName = "Sub")]
    [ValidateNotNullOrEmpty()]
    [string] $SubscriptionId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $WorkspaceName,

    [Parameter(Mandatory)]
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
    Get-LogAnalyticWorkspace @arguments

    $alertId = (Get-AzSentinelAlertRule -WorkspaceName $WorkspaceName -RuleName $RuleName).name

    if ($alertId) {
      $uri = "$($Script:baseUri)/providers/Microsoft.SecurityInsights/alertRules/$($alertId)/actions?api-version=2019-01-01-preview"
      $action = (Invoke-RestMethod -Uri $uri -Method Get -Headers $script:authHeader)
      return $action.value
    }
    else {
      Write-Error "No Action linked to Alert Rule $($RuleName)"
    }
  }
}

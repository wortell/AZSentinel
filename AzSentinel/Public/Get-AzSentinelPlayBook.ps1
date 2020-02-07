#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Get-AzSentinelPlayBook {
  <#
    .SYNOPSIS
    Get Logic App Playbook
    .DESCRIPTION
    This function is used by other function for resolving the Logic App thats compatible for use with Azure Sentinel
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER Name
    Enter the Logic App name
    .EXAMPLE
    Get-AzSentinelPlayBook -Name "pkmsentinel"
    This example will get search for the Logic app within the current subscripbtio and test to see if it's compatible for Sentinel
    .NOTES
    NAME: Get-AzSentinelPlayBook
  #>
  param (
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string] $SubscriptionId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Name
  )

  begin {
    precheck
  }

  process {
    if ($SubscriptionId) {
      Write-Verbose "Getting LogicApp from Subscription $($subscriptionId)"
      $uri = "https://management.azure.com/subscriptions/$($subscriptionId)/providers/Microsoft.Logic/workflows?api-version=2016-06-01"
    }
    elseif ($script:subscriptionId) {
      Write-Verbose "Getting LogicApp from Subscription $($script:subscriptionId)"
      $uri = "https://management.azure.com/subscriptions/$($script:subscriptionId)/providers/Microsoft.Logic/workflows?api-version=2016-06-01"
    }
    else {
      Write-Error "No SubscriptionID provided" -ErrorAction Stop
    }

    $playBook = (Invoke-RestMethod -Uri $uri -Method get -Headers $script:authHeader).value | Where-Object { $_.name -eq $Name }

    if ($playBook) {
      $uri1 = "https://management.azure.com$($playBook.id)/triggers/When_a_response_to_an_Azure_Sentinel_alert_is_triggered?api-version=2016-06-01"
      try {
        $playbookTrigger = (Invoke-RestMethod -Uri $uri1 -Method Get -Headers $script:authHeader).properties

        if ($playbookTrigger) {
          return $playBook
        }
        else {
          Write-Error "Playbook doesn't start with 'When_a_response_to_an_Azure_Sentinel_alert_is_triggered' step! " -ErrorAction Continue
        }
      }
      catch {
        Write-Error $_.Exception.Message
      }
    }
    else {
      Write-Error "Unable to find LogicApp $Name under Subscription Id: $($script:subscriptionId)" -ErrorAction Stop
    }
  }
}

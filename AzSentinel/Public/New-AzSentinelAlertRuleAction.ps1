

<#
New-AzSentinelAlertRuleAction -WorkspaceName pkm02 -PlayBookName "pkmsentinel" -RuleName "testrule01"

#>

function New-AzSentinelAlertRuleAction {
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
    [string] $PlayBookName,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$RuleName,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$RuleId
  )
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
      $alertId = (Get-AzSentinelAlertRule @arguments -RuleName $RuleName -ErrorAction SilentlyContinue).name
    }
    elseif ($RuleId) {
      $alertId = $RuleId
    }
    else {
      Write-Error "No Alert Name or ID is provided" -ErrorAction Continue
    }

    $playBook = Get-AzSentinelPlayBook -Name $PlayBookName -ErrorAction SilentlyContinue

    if ($playBook -and $alertId) {
      $action = Get-AzSentinelAlertRuleAction @arguments -RuleId $alertId -ErrorAction SilentlyContinue

      if ($action) {
        Write-Host "Alert Rule: $($alertId) has already playbook assigned: $(($action.properties.logicAppResourceId).Split('/')[-1])"
      }
      else {
        $guid = New-Guid


        $body = @{
          "id"         = "$($Script:baseUri)/providers/Microsoft.SecurityInsights/alertRules/$($alertId)/actions/$guid"
          "name"       = $guid
          "type"       = "Microsoft.SecurityInsights/alertRules/actions"
          "properties" = @{
            "ruleId"             =  $alertId
            "triggerUri"         = "$($playBook.properties.accessEndpoint)/triggers/When_a_response_to_an_Azure_Sentinel_alert_is_triggered/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2FWhen_a_response_to_an_Azure_Sentinel_alert_is_triggered%2Frun&sv=1.0&sig=NMCSM7uOK4I42L2IPWdgL2eR3-VpoKLXpbTzI9_7wvI"
            "logicAppResourceId" = "$($playBook.id)"
          }
        }

        $uri = "$($Script:baseUri)/providers/Microsoft.SecurityInsights/alertRules/$($alertId)/actions/$($guid)?api-version=2019-01-01-preview"
        try {
          $return = Invoke-WebRequest -Method Put -Uri $uri -Headers $Script:authHeader -Body ($body | ConvertTo-Json -Depth 10)
          Write-Host "Successfully created Action for Rule: $($RuleName) with Playbook $($PlayBookName) Status: $($return.StatusDescription)"
          Write-Verbose $return
        }
        catch {
          $return = $_.Exception.Message
          return $return
          Write-Verbose $_.
        }
      }
    }
    else {
      #Write-Error " unabkle "
    }
  }
}

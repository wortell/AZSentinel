#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function New-AzSentinelAlertRuleAction {
    <#
      .SYNOPSIS
      Create Azure Sentinal Alert Rule Action
      .DESCRIPTION
      Use this function to creates Azure Sentinal Alert rule action
      .PARAMETER SubscriptionId
      Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
      .PARAMETER WorkspaceName
      Enter the Workspace name
      .PARAMETER PlayBookName
      Enter the Playbook name that you want to assign to the alert rule
      .PARAMETER RuleName
      Enter the Alert Rule name that you want to configure
      .PARAMETER RuleId
      Enter the Alert Rule ID that you want to configure
      .EXAMPLE
      New-AzSentinelAlertRuleAction -WorkspaceName "" -PlayBookName "Playbook01" -RuleName "AlertRule01"
      New-AzSentinelAlertRuleAction -WorkspaceName "" -PlayBookName "Playbook01" -RuleId 'b6103d42-d2fb-4f35-xxx-c76a7f31ee4e'
      In this example you you assign the playbook to the Alert rule
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $false,
            ParameterSetName = "Sub")]
        [ValidateNotNullOrEmpty()]
        [string]$SubscriptionId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$PlayBookName,

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

        if ($RuleName) {
            $alertId = (Get-AzSentinelAlertRule @arguments -RuleName $RuleName -ErrorAction SilentlyContinue).name
        }
        elseif ($RuleId) {
            $alertId = $RuleId
        }
        else {
            Write-Error "No Alert Name or ID is provided"
        }

        $action = $null


        if ($SubscriptionId) {
            $playBook = Get-AzSentinelPlayBook -SubscriptionId $SubscriptionId -Name $PlayBookName
        }
        else {
            $playBook = Get-AzSentinelPlayBook -Name $PlayBookName
        }

        $action = Get-AzSentinelAlertRuleAction @arguments -RuleId $alertId -ErrorAction SilentlyContinue

        if (($null -eq $action) -or ((($action.properties.logicAppResourceId).Split('/')[-1]) -ne $PlayBookName.Split('/')[-1])) {
            $guid = New-Guid

            $body = @{
                "id"         = "$($Script:baseUri)/providers/Microsoft.SecurityInsights/alertRules/$($alertId)/actions/$guid"
                "name"       = $guid
                "type"       = "Microsoft.SecurityInsights/alertRules/actions"
                "properties" = @{
                    "ruleId"             = $alertId
                    "triggerUri"         = $playBook.value
                    "logicAppResourceId" = $playBook.ResourceId
                }
            }

            $uri = "$($Script:baseUri)/providers/Microsoft.SecurityInsights/alertRules/$($alertId)/actions/$($guid)?api-version=2019-01-01-preview"

            try {
                $return = Invoke-WebRequest -Method Put -Uri $uri -Headers $Script:authHeader -Body ($body | ConvertTo-Json -Depth 10)
                Write-Verbose "Successfully created Action for Rule: $($RuleName) with Playbook $($PlayBookName) Status: $($return.StatusDescription)"
                return $return.StatusDescription
            }
            catch {
                Write-Error "Unable to create Action for Rule: $($RuleName) with Playbook $($PlayBookName) Error: $($_.Exception.Message)"
                Write-Verbose $_
                return $_.Exception.Message
            }
        }
        elseif ((($action.properties.logicAppResourceId).Split('/')[-1]) -eq $PlayBookName) {
            Write-Output "Alert Rule: $($alertId) is already assigned to playbook: $(($action.properties.logicAppResourceId).Split('/')[-1])"
        }

        else {
            #nothing?
        }
    }
}

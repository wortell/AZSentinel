function Enable-AzSentinelAlertRule {
    <#
      .SYNOPSIS
      Enable Azure Sentinel Alert Rules
      .DESCRIPTION
      With this function you can enable Azure Sentinel Alert rule
      .PARAMETER SubscriptionId
      Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
      .PARAMETER WorkspaceName
      Enter the Workspace name
      .PARAMETER RuleName
      Enter the name of the Alert rule
      .EXAMPLE
      Enable-AzSentinelAlertRule -WorkspaceName "" -RuleName "",""
      In this example you can get configuration of multiple alert rules in once
    #>
    [cmdletbinding(SupportsShouldProcess)]
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

        try {
            $rules = Get-AzSentinelAlertRule @arguments -RuleName $RuleName -ErrorAction Stop
        }
        catch {
            $return = $_.Exception.Message
            Write-Error $return
        }

        foreach ($rule in $rules) {
            if ($rule.enabled -eq $true) {
                Write-Output "'$($rule.DisplayName)' already has status '$($rule.enabled)'"
            }
            else {
                $rule.enabled = $true
                $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/alertRules/$($rule.name)?api-version=2019-01-01-preview"

                $groupingConfiguration = [GroupingConfiguration]::new(
                    $rule.incidentConfiguration.groupingConfiguration.GroupingConfigurationEnabled,
                    $rule.incidentConfiguration.groupingConfiguration.ReopenClosedIncident,
                    $rule.incidentConfiguration.groupingConfiguration.LookbackDuration,
                    $rule.incidentConfiguration.groupingConfiguration.EntitiesMatchingMethod,
                    $rule.incidentConfiguration.groupingConfiguration.GroupByEntities
                )

                $incidentConfiguration = [IncidentConfiguration]::new(
                    $rule.incidentConfiguration.CreateIncident,
                    $groupingConfiguration
                )

                $bodyAlertProp = [ScheduledAlertProp]::new(
                    $rule.name,
                    $rule.DisplayName,
                    $rule.Description,
                    $rule.Severity,
                    $rule.Enabled,
                    $rule.Query,
                    $rule.QueryFrequency,
                    $rule.QueryPeriod,
                    $rule.TriggerOperator,
                    $rule.TriggerThreshold,
                    $rule.SuppressionDuration,
                    $rule.SuppressionEnabled,
                    $rule.Tactics,
                    $rule.PlaybookName,
                    $incidentConfiguration,
                    $rule.AggregationKind
                )

                $body = [AlertRule]::new( $rule.name, $rule.etag, $bodyAlertProp, $rule.Id, 'Scheduled')

                try {
                    $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json -Depth 10 -EnumsAsStrings)
                    Write-Verbose $result
                    Write-Output "Status of '$($rule.DisplayName)' changed to '$($rule.enabled)'"
                }
                catch {
                    Write-Error $_.Exception.Message
                }
            }
        }
    }
}

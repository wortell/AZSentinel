#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function New-AzSentinelAlertRule {
    <#
    .SYNOPSIS
    Create Azure Sentinal Alert Rules
    .DESCRIPTION
    Use this function creates Azure Sentinal Alert rules from provided CMDLET
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER WorkspaceName
    Enter the Workspace name
    .PARAMETER Kind
    The alert rule kind
    .PARAMETER DisplayName
    The display name for alerts created by this alert rule.
    .PARAMETER Description
    The description of the alert rule.
    .PARAMETER Severity
    Enter the Severity, valid values: Medium", "High", "Low", "Informational"
    .PARAMETER Enabled
    Determines whether this alert rule is enabled or disabled.
    .PARAMETER Query
    The query that creates alerts for this rule.
    .PARAMETER QueryFrequency
    Enter the query frequency, example: 5H, 5M, 5D (H stands for Hour, M stands for Minute and D stands for Day)
    .PARAMETER QueryPeriod
    Enter the query period, exmaple: 5H, 5M, 5D (H stands for Hour, M stands for Minute and D stands for Day)
    .PARAMETER TriggerOperator
    Select the triggert Operator, valid values are: "GreaterThan", "FewerThan", "EqualTo", "NotEqualTo"
    .PARAMETER TriggerThreshold
    Enter the trigger treshold
    .PARAMETER SuppressionDuration
    Enter the suppression duration, example: 5H, 5M, 5D (H stands for Hour, M stands for Minute and D stands for Day)
    .PARAMETER SuppressionEnabled
    Set $true to enable Suppression or $false to disable Suppression
    .PARAMETER Tactics
    Enter the Tactics, valid values: "InitialAccess", "Persistence", "Execution", "PrivilegeEscalation", "DefenseEvasion", "CredentialAccess", "LateralMovement", "Discovery", "Collection", "Exfiltration", "CommandAndControl", "Impact"
    .PARAMETER PlaybookName
    Enter the Logic App name that you want to configure as playbook trigger
    .PARAMETER CreateIncident
    Create incidents from alerts triggered by this analytics rule
    .PARAMETER GroupingConfigurationEnabled
    Group related alerts, triggered by this analytics rule, into incidents
    .PARAMETER ReopenClosedIncident
    Re-open closed matching incidents
    .PARAMETER LookbackDuration
    Limit the group to alerts created within the selected time frame
    .PARAMETER EntitiesMatchingMethod
    Group alerts triggered by this analytics rule into a single incident by
    .PARAMETER GroupByEntities
    Grouping alerts into a single incident if the selected entities match:
    .PARAMETER AggregationKind
    Configure how rule query results are grouped into alerts
    .PARAMETER AlertRuleTemplateName
    The Name of the alert rule template used to create this rule
    .PARAMETER ProductFilter
    The alerts' productName on which the cases will be generated
    .PARAMETER SeveritiesFilter
    The alerts' severities on which the cases will be generated
    .PARAMETER DisplayNamesFilter
    The alerts' displayNames on which the cases will be generated
    .EXAMPLE
    New-AzSentinelAlertRule -WorkspaceName "" -DisplayName "" -Description "" -Severity -Enabled $true -Query '' -QueryFrequency "" -QueryPeriod "" -TriggerOperator -TriggerThreshold  -SuppressionDuration "" -SuppressionEnabled $false -Tactics @("","") -PlaybookName ""
    Example on how to create a scheduled rule
    .EXAMPLE
    New-AzSentinelAlertRule -WorkspaceName "" -Kind Fusion -DisplayName "Advanced Multistage Attack Detection" -Enabled $true -AlertRuleTemplateName "f71aba3d-28fb-450b-b192-4e76a83015c8"
    Example on how to create a Fusion rule
    .EXAMPLE
    New-AzSentinelAlertRule -WorkspaceName "" -Kind MLBehaviorAnalytics -DisplayName "(Preview) Anomalous SSH Login Detection" -Enabled $true -AlertRuleTemplateName "fa118b98-de46-4e94-87f9-8e6d5060b60b"
    Example on how to create a MLBehaviorAnalytics rule
    .EXAMPLE
    New-AzSentinelAlertRule -WorkspaceName "" -Kind MicrosoftSecurityIncidentCreation -DisplayName "" -Description "" -Enabled $true -ProductFilter "" -SeveritiesFilter "","" -DisplayNamesFilter ""
    Example on how to create a MicrosoftSecurityIncidentCreation rule
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $false, ParameterSetName = "Sub")]
        [ValidateNotNullOrEmpty()]
        [string]$SubscriptionId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $false)]
        [Kind]$Kind = 'Scheduled',

        [Parameter(Mandatory = $false)]
        [string]$DisplayName,

        [Parameter(Mandatory = $false)]
        [string]$Description,

        [Parameter(Mandatory = $false)]
        [Severity]$Severity,

        [Parameter(Mandatory = $false)]
        [bool]$Enabled,

        [Parameter(Mandatory = $false)]
        [string]$Query,

        [Parameter(Mandatory = $false)]
        [string]$QueryFrequency,

        [parameter(Mandatory = $false)]
        [string]$QueryPeriod,

        [Parameter(Mandatory = $false)]
        [TriggerOperator]$TriggerOperator,

        [Parameter(Mandatory = $false)]
        [Int]$TriggerThreshold,

        [Parameter(Mandatory = $false)]
        [string]$SuppressionDuration,

        [Parameter(Mandatory = $false)]
        [bool]$SuppressionEnabled,

        [Parameter(Mandatory = $false)]
        #[Tactics[]] $Tactics,
        [string[]]$Tactics,

        [Parameter(Mandatory = $false)]
        [string[]]$PlaybookName = '',

        [Parameter(Mandatory = $false)]
        [bool]$CreateIncident,

        [Parameter(Mandatory = $false)]
        [bool]$GroupingConfigurationEnabled,

        [Parameter(Mandatory = $false)]
        [bool]$ReopenClosedIncident,

        [Parameter(Mandatory = $false)]
        [string]$LookbackDuration,

        [Parameter(Mandatory = $false)]
        [MatchingMethod]$EntitiesMatchingMethod,

        [Parameter(Mandatory = $false)]
        #[groupByEntities[]]$GroupByEntities,
        [string[]]$GroupByEntities,

        [Parameter(Mandatory = $false)]
        [AggregationKind]$AggregationKind,

        #Fusion & MLBehaviorAnalytics & Scheduled
        [Parameter(Mandatory = $false)]
        [string]$AlertRuleTemplateName,

        #MicrosoftSecurityIncidentCreation
        [Parameter(Mandatory = $false)]
        [string]$ProductFilter,

        [Parameter(Mandatory = $false)]
        [Severity[]]$SeveritiesFilter,

        [Parameter(Mandatory = $false)]
        [string]$DisplayNamesFilter
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

        $item = @{ }

        Write-Verbose -Message "Creating new rule: $($DisplayName)"

        try {
            $content = Get-AzSentinelAlertRule @arguments -RuleName $DisplayName -ErrorAction Stop
        }
        catch {
            Write-Error $_.Exception.Message
            break
        }

        if ($content) {
            Write-Verbose -Message "Rule $($DisplayName) exists in Azure Sentinel"

            $item | Add-Member -NotePropertyName name -NotePropertyValue $content.name -Force
            $item | Add-Member -NotePropertyName etag -NotePropertyValue $content.eTag -Force
            $item | Add-Member -NotePropertyName Id -NotePropertyValue $content.id -Force

            $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/alertRules/$($content.name)?api-version=2019-01-01-preview"
        }
        else {
            Write-Verbose -Message "Rule $($DisplayName) doesn't exists in Azure Sentinel"

            $guid = (New-Guid).Guid

            $item | Add-Member -NotePropertyName name -NotePropertyValue $guid -Force
            $item | Add-Member -NotePropertyName etag -NotePropertyValue $null -Force
            $item | Add-Member -NotePropertyName Id -NotePropertyValue "$script:Workspace/providers/Microsoft.SecurityInsights/alertRules/$guid" -Force

            $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/alertRules/$($guid)?api-version=2019-01-01-preview"
        }

        if ($Kind -eq 'Scheduled') {

            try {
                $groupingConfiguration = [GroupingConfiguration]::new(
                    $GroupingConfigurationEnabled,
                    $ReopenClosedIncident,
                    $LookbackDuration,
                    $EntitiesMatchingMethod,
                    $GroupByEntities
                )

                $incidentConfiguration = [IncidentConfiguration]::new(
                    $CreateIncident,
                    $groupingConfiguration
                )

                if (($AlertRuleTemplateName -and ! $content) -or $content.AlertRuleTemplateName) {
                    if ($content.AlertRuleTemplateName){
                        <#
                            If alertRule is already created with a TemplateName then Always use template name from existing rule.
                            You can't attach existing scheduled rule to another templatename or remove the link to the template
                        #>
                        $AlertRuleTemplateName = $content.AlertRuleTemplateName
                    }
                    $bodyAlertProp = [ScheduledAlertProp]::new(
                        $item.name,
                        $DisplayName,
                        $Description,
                        $Severity,
                        $Enabled,
                        $Query,
                        $QueryFrequency,
                        $QueryPeriod,
                        $TriggerOperator,
                        $TriggerThreshold,
                        $SuppressionDuration,
                        $SuppressionEnabled,
                        $Tactics,
                        $PlaybookName,
                        $incidentConfiguration,
                        $AggregationKind,
                        $AlertRuleTemplateName
                    )
                } else {
                    $bodyAlertProp = [ScheduledAlertProp]::new(
                        $item.name,
                        $DisplayName,
                        $Description,
                        $Severity,
                        $Enabled,
                        $Query,
                        $QueryFrequency,
                        $QueryPeriod,
                        $TriggerOperator,
                        $TriggerThreshold,
                        $SuppressionDuration,
                        $SuppressionEnabled,
                        $Tactics,
                        $PlaybookName,
                        $incidentConfiguration,
                        $AggregationKind
                    )
                }

                $body = [AlertRule]::new( $item.name, $item.etag, $bodyAlertProp, $item.Id, 'Scheduled')
            }
            catch {
                Write-Error "Unable to initiate class with error: $($_.Exception.Message)" -ErrorAction Stop
            }

            if ($content) {
                if ($PlaybookName -or $content.playbookName) {
                    $compareResult = Compare-Policy -ReferenceTemplate ($content | Select-Object * -ExcludeProperty lastModifiedUtc, alertRuleTemplateName, name, etag, id) -DifferenceTemplate ($body.Properties | Select-Object * -ExcludeProperty name)
                }
                else {
                    $compareResult = Compare-Policy -ReferenceTemplate ($content | Select-Object * -ExcludeProperty lastModifiedUtc, alertRuleTemplateName, name, etag, id, PlaybookName) -DifferenceTemplate ($body.Properties | Select-Object * -ExcludeProperty name, PlaybookName)
                }

                try {
                    $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json -Depth 10 -EnumsAsStrings)

                    if (($compareResult | Where-Object PropertyName -eq "playbookName").DiffValue) {
                        foreach ($playbook in ($body.Properties.PlaybookName)) {
                            $PlaybookResult = New-AzSentinelAlertRuleAction @arguments -PlayBookName $playbook -RuleId $($body.Name) -confirm:$false
                            $body.Properties | Add-Member -NotePropertyName PlaybookStatus -NotePropertyValue $PlaybookResult -Force
                        }
                    }
                    elseif (($compareResult | Where-Object PropertyName -eq "playbookName").RefValue) {
                        $PlaybookResult = Remove-AzSentinelAlertRuleAction @arguments -RuleId $($body.Name) -Confirm:$false
                        $body.Properties | Add-Member -NotePropertyName PlaybookStatus -NotePropertyValue $PlaybookResult -Force
                    }
                    else {
                        #nothing
                    }

                    $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue $($result.StatusDescription) -Force
                    $body.Properties | Add-Member -NotePropertyName Kind -NotePropertyValue "Scheduled" -Force
                    $return += $body.Properties

                    return $return
                }
                catch {
                    $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue "failed" -Force
                    $body.Properties | Add-Member -NotePropertyName Kind -NotePropertyValue "Scheduled" -Force
                    $return += $body.Properties

                    Write-Verbose $_
                    Write-Error "Unable to invoke webrequest for rule $($item.displayName) with error message: $($_.Exception.Message)" -ErrorAction Continue

                    return $return
                }
            }
            else {
                Write-Verbose "Creating new rule: $($DisplayName)"

                try {
                    $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json -Depth 10 -EnumsAsStrings)
                    if (($body.Properties.PlaybookName)) {
                        foreach ($playbook in ($body.Properties.PlaybookName)) {
                            New-AzSentinelAlertRuleAction @arguments -PlayBookName $playbook -RuleId $($body.Name) -confirm:$false
                            $body.Properties | Add-Member -NotePropertyName PlaybookStatus -NotePropertyValue $PlaybookResult -Force
                        }
                    }

                    $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue $($result.StatusDescription) -Force
                    $body.Properties | Add-Member -NotePropertyName Kind -NotePropertyValue "Scheduled" -Force
                    $return += $body.Properties
                    return $return
                }
                catch {
                    $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue "failed" -Force
                    $body.Properties | Add-Member -NotePropertyName Kind -NotePropertyValue "Scheduled" -Force
                    $return += $body.Properties
                    return $return

                    Write-Verbose $_
                    Write-Error "Unable to invoke webrequest for rule $($item.displayName) with error message: $($_.Exception.Message)" -ErrorAction Continue
                }
            }
        }

        if ($Kind -eq 'Fusion') {

            $bodyAlertProp = [Fusion]::new(
                $Enabled,
                $AlertRuleTemplateName
            )

            $body = [AlertRule]::new( $item.name, $item.etag, $bodyAlertProp, $item.Id, 'Fusion')

            try {
                $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json -Depth 10 -EnumsAsStrings)
                $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue $($result.StatusDescription) -Force
                $body.Properties | Add-Member -NotePropertyName Kind -NotePropertyValue "Fusion" -Force
                $return += $body.Properties

                return $return
            }
            catch {
                $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue "failed" -Force
                $body.Properties | Add-Member -NotePropertyName Kind -NotePropertyValue "Fusion" -Force
                $return += $body.Properties

                return $return

                Write-Verbose $_
                Write-Verbose "Unable to invoke webrequest for rule $($item.displayName) with error message: $($_.Exception.Message)" -ErrorAction Continue
            }
        }

        if ($Kind -eq 'MLBehaviorAnalytics') {

            $bodyAlertProp = [MLBehaviorAnalytics]::new(
                $Enabled,
                $AlertRuleTemplateName
            )

            $body = [AlertRule]::new( $item.name, $item.etag, $bodyAlertProp, $item.Id, 'MLBehaviorAnalytics')

            try {
                $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json -Depth 10 -EnumsAsStrings)
                $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue $($result.StatusDescription) -Force
                $body.Properties | Add-Member -NotePropertyName Kind -NotePropertyValue "MLBehaviorAnalytics" -Force
                $return += $body.Properties

                return $return
            }
            catch {
                $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue "failed" -Force
                $body.Properties | Add-Member -NotePropertyName Kind -NotePropertyValue "MLBehaviorAnalytics" -Force
                $return += $body.Properties

                return $return

                Write-Verbose $_
                Write-Verbose "Unable to invoke webrequest for rule $($item.displayName) with error message: $($_.Exception.Message)" -ErrorAction Continue
            }
        }

        if ($Kind -eq 'MicrosoftSecurityIncidentCreation') {

            $bodyAlertProp = [MicrosoftSecurityIncidentCreation]::new(
                $DisplayName,
                $Description,
                $Enabled,
                $ProductFilter,
                $SeveritiesFilter,
                $DisplayNamesFilter
            )

            $body = [AlertRule]::new( $item.name, $item.etag, $bodyAlertProp, $item.Id, 'MicrosoftSecurityIncidentCreation')

            try {
                $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json -Depth 10 -EnumsAsStrings)

                $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue $($result.StatusDescription) -Force
                $body.Properties | Add-Member -NotePropertyName Kind -NotePropertyValue "MicrosoftSecurityIncidentCreation" -Force
                $return += $body.Properties

                return $return
            }
            catch {
                $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue "failed" -Force
                $body.Properties | Add-Member -NotePropertyName Kind -NotePropertyValue "MicrosoftSecurityIncidentCreation" -Force
                $return += $body.Properties

                return $return

                Write-Verbose $_
                Write-Verbose "Unable to invoke webrequest for rule $($item.displayName) with error message: $($_.Exception.Message)" -ErrorAction Continue
            }
        }
    }
}

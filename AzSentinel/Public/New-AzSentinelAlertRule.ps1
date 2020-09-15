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
    .PARAMETER DisplayName
    Enter the Display name for the Alert rule
    .PARAMETER Description
    Enter the Description for the Alert rule
    .PARAMETER Severity
    Enter the Severity, valid values: Medium", "High", "Low", "Informational"
    .PARAMETER Enabled
    Set $true to enable the Alert Rule or $false to disable Alert Rule
    .PARAMETER Query
    Enter the Query that you want to use
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
    .EXAMPLE
    New-AzSentinelAlertRule -WorkspaceName "" -DisplayName "" -Description "" -Severity -Enabled $true -Query '' -QueryFrequency "" -QueryPeriod "" -TriggerOperator -TriggerThreshold  -SuppressionDuration "" -SuppressionEnabled $false -Tactics @("","") -PlaybookName ""
    In this example you create a new Alert rule by defining the rule properties from CMDLET
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $false, ParameterSetName = "Sub")]
        [ValidateNotNullOrEmpty()]
        [string] $SubscriptionId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $WorkspaceName,

        [Parameter(Mandatory)]
        [string] $DisplayName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Description,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Severity] $Severity,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [bool] $Enabled,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Query,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $QueryFrequency,

        [ValidateNotNullOrEmpty()]
        [string] $QueryPeriod,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [TriggerOperator] $TriggerOperator,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Int] $TriggerThreshold,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $SuppressionDuration,

        [Parameter(Mandatory)]
        [bool] $SuppressionEnabled,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        #[Tactics[]] $Tactics,
        [string[]] $Tactics,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [string] $PlaybookName = $null,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [bool]$CreateIncident,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [bool]$GroupingConfigurationEnabled,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [bool]$ReopenClosedIncident,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [string]$LookbackDuration,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [MatchingMethod]$EntitiesMatchingMethod,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        #[groupByEntities[]]$GroupByEntities,
        [string[]]$GroupByEntities,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [string]$AggregationKind
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
            Write-Verbose -Message "Get rule $DisplayName"
            $content = Get-AzSentinelAlertRule @arguments -RuleName $DisplayName -ErrorAction SilentlyContinue

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
        }
        catch {
            Write-Verbose $_
            Write-Error "Unable to connect to APi to get Analytic rules with message: $($_.Exception.Message)" -ErrorAction Stop
        }

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

            $body = [AlertRule]::new( $item.name, $item.etag, $bodyAlertProp, $item.Id)
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
                    New-AzSentinelAlertRuleAction @arguments -PlayBookName ($body.Properties.playbookName) -RuleId $($body.Name)
                }
                elseif (($compareResult | Where-Object PropertyName -eq "playbookName").RefValue) {
                    Remove-AzSentinelAlertRuleAction @arguments -RuleId $($body.Name) -Confirm:$false
                }
                else {
                    #nothing
                }

                $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue $($result.StatusDescription) -Force
                $return += $body.Properties
                return $return
            }
            catch {
                $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue "failed" -Force
                $return += $body.Properties
                return $return

                Write-Verbose $_
                Write-Error "Unable to invoke webrequest for rule $($item.displayName) with error message: $($_.Exception.Message)" -ErrorAction Continue
            }
        }
        else {
            Write-Verbose "Creating new rule: $($DisplayName)"

            try {
                $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json -Depth 10 -EnumsAsStrings)
                if (($body.Properties.PlaybookName)) {
                    New-AzSentinelAlertRuleAction @arguments -PlayBookName ($body.Properties.PlaybookName) -RuleId $($body.Properties.Name) -confirm:$false
                }

                $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue $($result.StatusDescription) -Force
                $return += $body.Properties
                return $return
            }
            catch {
                $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue "failed" -Force
                $return += $body.Properties
                return $return

                Write-Verbose $_
                Write-Error "Unable to invoke webrequest for rule $($item.displayName) with error message: $($_.Exception.Message)" -ErrorAction Continue
            }
        }
    }
}

#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Import-AzSentinelAlertRule {
    <#
    .SYNOPSIS
    Import Azure Sentinal Alert rule
    .DESCRIPTION
    This function imports Azure Sentinal Alert rules from JSON and YAML config files.
    This way you can manage your Alert rules dynamic from JSON or multiple YAML files
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER WorkspaceName
    Enter the Workspace name
    .PARAMETER SettingsFile
    Path to the JSON or YAML file for the AlertRules
    .EXAMPLE
    Import-AzSentinelAlertRule -WorkspaceName "" -SettingsFile ".\examples\AlertRules.json"
    In this example all the rules configured in the JSON file will be created or updated

    Performing the operation "Import-AzSentinelAlertRule" on target "Do you want to update profile: AlertRule01".
    [Y] Yes [A] Yes to All [N] No [L] No to All [S] Suspend [?] Help (default is "Yes"):
    Successfully created Action for Rule:  with Playbook pkmsentinel Status: Created
    Created
    Successfully updated rule: AlertRule01 with status: OK

    Name                : b6103d42-xxx-4f35-xxx-c76a7f31ee4e
    DisplayName         : AlertRule01
    Description         :
    Severity            : Medium
    Enabled             : True
    Query               : SecurityEvent | where EventID == "4688" | where CommandLine contains "-noni -ep bypass $"
    QueryFrequency      : PT5H
    QueryPeriod         : PT6H
    TriggerOperator     : GreaterThan
    TriggerThreshold    : 5
    SuppressionDuration : PT6H
    SuppressionEnabled  : False
    Tactics             : {Persistence, LateralMovement, Collection}
    PlaybookName        : Playbook01

    .EXAMPLE
    Import-AzSentinelAlertRule -WorkspaceName "" -SettingsFile ".\examples\SuspectApplicationConsent.yaml"
    In this example all the rules configured in the YAML file will be created or updated
    .EXAMPLE
    Get-Item .\examples\*.json | Import-AzSentinelAlertRule -WorkspaceName ""
    In this example you can select multiple JSON files and Pipeline it to the SettingsFile parameter
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

        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript( { (Test-Path -Path $_) -and ($_.Extension -in '.json', '.yaml', '.yml') })]
        [System.IO.FileInfo] $SettingsFile
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

        if ($SettingsFile.Extension -eq '.json') {
            try {
                $rulesRaw = Get-Content $SettingsFile -Raw
                $rules = $rulesRaw | ConvertFrom-Json -Depth 99
                Write-Verbose -Message "Found $($rules.count) rules"
            }
            catch {
                Write-Verbose $_
                Write-Error -Message 'Unable to import JSON file' -ErrorAction Stop
            }
        }
        elseif ($SettingsFile.Extension -in '.yaml', '.yml') {
            try {
                $rules = [pscustomobject](Get-Content $SettingsFile -Raw | ConvertFrom-Yaml -ErrorAction Stop)
                $rules | Add-Member -MemberType NoteProperty -Name DisplayName -Value $rules.name
                Write-Verbose -Message 'Found compatibel yaml file'
            }
            catch {
                Write-Verbose $_
                Write-Error -Message 'Unable to convert yaml file' -ErrorAction Stop
            }
        }
        else {
            Write-Error -Message 'Unsupported extension for SettingsFile' -ErrorAction Stop
        }

        $return = @()

        <#
        Test All rules first
        #>
        if($rules.analytics -or $rules.Scheduled -or $rules.fusion -or $rules.MLBehaviorAnalytics -or $rules.MicrosoftSecurityIncidentCreation)
        {
            $allRules = $rules.analytics + $rules.Scheduled + $rules.fusion + $rules.MLBehaviorAnalytics + $rules.MicrosoftSecurityIncidentCreation | Select-Object displayName
            try {
                Write-Verbose -Message "Found $($allRules.displayName.Count) rules in the settings file."
                $allRulesContent = Get-AzSentinelAlertRule @arguments -RuleName $($allRules.displayName) -ErrorAction Stop
            }
            catch {
                Write-Error $_.Exception.Message
                break
            }
        }
        
        <#
            Analytics rule
            Take the raw rule configuration if it is not nested in "analytics", "Scheduled", "fusion", "MLBehaviorAnalytics" or "MicrosoftIncidentCreation"
        #>
        if (-not $rules.analytics -and -not $rules.Scheduled -and -not $rules.fusion -and -not $rules.MLBehaviorAnalytics -and -not $rules.MicrosoftSecurityIncidentCreation){
            Write-Verbose -Message "Settings file is not nested in root schema, using raw configuration."
            $scheduled = $rules
        }
        elseif ($rules.analytics) {
            $scheduled = $rules.analytics
        }
        else{
            $scheduled = $rules.Scheduled
        }
        
        foreach ($item in $scheduled) {
            Write-Verbose -Message "Started with rule: $($item.displayName)"

            $guid = (New-Guid).Guid
            if($allRulesContent)
            {
                $content = $allRulesContent | Where-Object {$_.kind -eq 'Scheduled' -and $_.displayName -eq $item.displayName}
            }
            else{
                $content = Get-AzSentinelAlertRule @arguments -RuleName $($item.displayName) -ErrorAction Stop
            }

            Write-Verbose -Message "Get rule $($item.description)"

            if ($content) {
                Write-Verbose "Rule $($item.displayName) exists in Azure Sentinel"

                $item | Add-Member -NotePropertyName name -NotePropertyValue $content.name -Force
                $item | Add-Member -NotePropertyName etag -NotePropertyValue $content.etag -Force
                $item | Add-Member -NotePropertyName Id -NotePropertyValue $content.id -Force

                $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/alertRules/$($content.name)?api-version=2019-01-01-preview"
            }
            else {
                Write-Verbose -Message "Rule $($item.displayName) doesn't exist in Azure Sentinel"

                $item | Add-Member -NotePropertyName name -NotePropertyValue $guid -Force
                $item | Add-Member -NotePropertyName etag -NotePropertyValue $null -Force
                $item | Add-Member -NotePropertyName Id -NotePropertyValue "$script:Workspace/providers/Microsoft.SecurityInsights/alertRules/$guid" -Force
                $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/alertRules/$($guid)?api-version=2019-01-01-preview"
            }

            # The official API schema indicates that the grouping configuration is part of the incident configuration
            try {
                # Added if/else statement for backwards compatibility
                if($item.incidentConfiguration){
                    $groupingConfiguration = [GroupingConfiguration]::new(
                        $item.incidentConfiguration.groupingConfiguration.enabled,
                        $item.incidentConfiguration.groupingConfiguration.reopenClosedIncident,
                        $item.incidentConfiguration.groupingConfiguration.lookbackDuration,
                        $item.incidentConfiguration.groupingConfiguration.entitiesMatchingMethod,
                        $item.incidentConfiguration.groupingConfiguration.groupByEntities
                    )
                    $incidentConfiguration = [IncidentConfiguration]::new(
                        $item.incidentConfiguration.createIncident,
                        $groupingConfiguration
                    )
                }
                else{
                    $groupingConfiguration = [GroupingConfiguration]::new(
                        $item.groupingConfiguration.enabled,
                        $item.groupingConfiguration.reopenClosedIncident,
                        $item.groupingConfiguration.lookbackDuration,
                        $item.groupingConfiguration.entitiesMatchingMethod,
                        $item.groupingConfiguration.groupByEntities
                    )
                    $incidentConfiguration = [IncidentConfiguration]::new(
                        $item.createIncident,
                        $groupingConfiguration
                    )
                    Write-Warning -Message "`"$($item.displayName)`" configuration is not following the official API schema, consider updating the incident and grouping configuration."
                }
                
                if (($item.AlertRuleTemplateName -and ! $content) -or $content.AlertRuleTemplateName){
                    if ($content.AlertRuleTemplateName){
                        <#
                            If alertRule is already created with a TemplateName then Always use template name from existing rule.
                            You can't attach existing scheduled rule to another templatename or remove the link to the template
                        #>
                        $item | Add-Member -NotePropertyName AlertRuleTemplateName -NotePropertyValue $content.AlertRuleTemplateName -Force
                    }
                    $bodyAlertProp = [ScheduledAlertProp]::new(
                        $item.name,
                        $item.displayName,
                        $item.description,
                        $item.severity,
                        $item.enabled,
                        $item.query,
                        $item.queryFrequency,
                        $item.queryPeriod,
                        $item.triggerOperator,
                        $item.triggerThreshold,
                        $item.suppressionDuration,
                        $item.suppressionEnabled,
                        $item.Tactics,
                        $item.playbookName,
                        $incidentConfiguration,
                        $item.aggregationKind,
                        $item.AlertRuleTemplateName
                    )
                } else {
                    $bodyAlertProp = [ScheduledAlertProp]::new(
                        $item.name,
                        $item.displayName,
                        $item.description,
                        $item.severity,
                        $item.enabled,
                        $item.query,
                        $item.queryFrequency,
                        $item.queryPeriod,
                        $item.triggerOperator,
                        $item.triggerThreshold,
                        $item.suppressionDuration,
                        $item.suppressionEnabled,
                        $item.Tactics,
                        $item.playbookName,
                        $incidentConfiguration,
                        $item.aggregationKind
                    )
                }
                $body = [AlertRule]::new( $item.name, $item.etag, $bodyAlertProp, $item.Id, 'Scheduled')
            }
            catch {
                Write-Error "Unable to initiate class with error: $($_.Exception.Message)" -ErrorAction Stop
            }

            if ($content) {
                if ($item.playbookName -or $content.playbookName) {
                    $compareResult = Compare-Policy -ReferenceTemplate ($content | Select-Object * -ExcludeProperty lastModifiedUtc, alertRuleTemplateName, name, etag, id, incidentConfiguration, queryResultsAggregationSettings) -DifferenceTemplate ($body.Properties | Select-Object * -ExcludeProperty lastModifiedUtc, alertRuleTemplateName, name, etag, id, incidentConfiguration, queryResultsAggregationSettings)
                }
                else {
                    $compareResult = Compare-Policy -ReferenceTemplate ($content | Select-Object * -ExcludeProperty lastModifiedUtc, alertRuleTemplateName, name, etag, id, PlaybookName, incidentConfiguration, queryResultsAggregationSettings) -DifferenceTemplate ($body.Properties | Select-Object * -ExcludeProperty name, PlaybookName, incidentConfiguration, queryResultsAggregationSettings)
                }
                try {
                    $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | Select-Object * -ExcludeProperty Properties.PlaybookName | ConvertTo-Json -Depth 10 -EnumsAsStrings)

                    if (($compareResult | Where-Object PropertyName -eq "playbookName").DiffValue) {
                        $PlaybookResult = New-AzSentinelAlertRuleAction @arguments -PlayBookName $($item.playbookName) -RuleId $($body.Name)
                        $body.Properties | Add-Member -NotePropertyName PlaybookStatus -NotePropertyValue $PlaybookResult -Force
                    }
                    elseif (($compareResult | Where-Object PropertyName -eq "playbookName").RefValue) {
                        $PlaybookResult = Remove-AzSentinelAlertRuleAction @arguments -RuleId $body.Name -Confirm:$false
                        $body.Properties | Add-Member -NotePropertyName PlaybookStatus -NotePropertyValue $PlaybookResult -Force
                    }
                    else {
                        #nothing
                    }
                    $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue $($result.StatusDescription) -Force
                    $body.Properties | Add-Member -NotePropertyName Kind -NotePropertyValue "Scheduled" -Force
                    $return += $body.Properties
                }
                catch {
                    $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue "failed" -Force
                    $body.Properties | Add-Member -NotePropertyName Kind -NotePropertyValue "Scheduled" -Force
                    $return += $body.Properties

                    Write-Verbose $_
                    Write-Error "Unable to invoke webrequest for rule $($item.displayName) with error message: $($_.Exception.Message)" -ErrorAction Continue
                }
            }
            else {
                Write-Verbose "Creating new rule: $($item.displayName)"

                try {
                    $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | Select-Object * -ExcludeProperty Properties.PlaybookName | ConvertTo-Json -Depth 10 -EnumsAsStrings)

                    if ($body.Properties.playbookName) {
                        $PlaybookResult = New-AzSentinelAlertRuleAction @arguments -PlayBookName $($item.playbookName) -RuleId $($body.Name) -confirm:$false
                        $body.Properties | Add-Member -NotePropertyName PlaybookStatus -NotePropertyValue $PlaybookResult -Force
                    }

                    $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue $($result.StatusDescription) -Force
                    $body.Properties | Add-Member -NotePropertyName Kind -NotePropertyValue "Scheduled" -Force
                    $return += $body.Properties
                }
                catch {
                    $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue "failed" -Force
                    $body.Properties | Add-Member -NotePropertyName Kind -NotePropertyValue "Scheduled" -Force
                    $return += $body.Properties

                    Write-Verbose $_
                    Write-Error "Unable to invoke webrequest for rule $($item.displayName) with error message: $($_.Exception.Message)" -ErrorAction Continue
                }
            }
        }

        <#
            Fusion rule
        #>
        foreach ($item in $rules.fusion) {
            Write-Verbose "Rule type is Fusion"

            $guid = (New-Guid).Guid

            $content = $allRulesContent | Where-Object {$_.kind -eq 'Fusion' -and $_.displayName -eq $item.displayName}

            Write-Verbose -Message "Get rule $($item.description)"

            if ($content) {
                Write-Verbose "Rule $($item.displayName) exists in Azure Sentinel"

                $item | Add-Member -NotePropertyName name -NotePropertyValue $content.name -Force
                $item | Add-Member -NotePropertyName etag -NotePropertyValue $content.etag -Force
                $item | Add-Member -NotePropertyName Id -NotePropertyValue $content.id -Force

                $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/alertRules/$($content.name)?api-version=2019-01-01-preview"
            }
            else {
                Write-Verbose -Message "Rule $($item.displayName) doesn't exist in Azure Sentinel"

                $item | Add-Member -NotePropertyName name -NotePropertyValue $guid -Force
                $item | Add-Member -NotePropertyName etag -NotePropertyValue $null -Force
                $item | Add-Member -NotePropertyName Id -NotePropertyValue "$script:Workspace/providers/Microsoft.SecurityInsights/alertRules/$guid" -Force
                $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/alertRules/$($guid)?api-version=2019-01-01-preview"
            }

            $bodyAlertProp = [Fusion]::new(
                $item.enabled,
                $item.alertRuleTemplateName
            )

            $body = [AlertRule]::new( $item.name, $item.etag, $bodyAlertProp, $item.Id, 'Fusion')

            try {
                $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json -Depth 10 -EnumsAsStrings)
                $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue $($result.StatusDescription) -Force
                $body.Properties | Add-Member -NotePropertyName Kind -NotePropertyValue "Fusion" -Force
                $return += $body.Properties
            }
            catch {
                $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue "failed" -Force
                $body.Properties | Add-Member -NotePropertyName Kind -NotePropertyValue "Fusion" -Force
                $return += $body.Properties

                Write-Verbose $_
                Write-Verbose "Unable to invoke webrequest for rule $($item.displayName) with error message: $($_.Exception.Message)" -ErrorAction Continue
            }
        }

        <#
            MLBehaviorAnalytics
        #>
        foreach ($item in $rules.MLBehaviorAnalytics) {
            Write-Verbose "Rule type is ML Behavior Analytics"

            $guid = (New-Guid).Guid

            $content = $allRulesContent | Where-Object {$_.kind -eq 'MLBehaviorAnalytics' -and $_.displayName -eq $item.displayName}

            Write-Verbose -Message "Get rule $($item.description)"

            if ($content) {
                Write-Verbose "Rule $($item.displayName) exists in Azure Sentinel"

                $item | Add-Member -NotePropertyName name -NotePropertyValue $content.name -Force
                $item | Add-Member -NotePropertyName etag -NotePropertyValue $content.etag -Force
                $item | Add-Member -NotePropertyName Id -NotePropertyValue $content.id -Force

                $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/alertRules/$($content.name)?api-version=2019-01-01-preview"
            }
            else {
                Write-Verbose -Message "Rule $($item.displayName) doesn't exist in Azure Sentinel"

                $item | Add-Member -NotePropertyName name -NotePropertyValue $guid -Force
                $item | Add-Member -NotePropertyName etag -NotePropertyValue $null -Force
                $item | Add-Member -NotePropertyName Id -NotePropertyValue "$script:Workspace/providers/Microsoft.SecurityInsights/alertRules/$guid" -Force
                $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/alertRules/$($guid)?api-version=2019-01-01-preview"
            }

            $bodyAlertProp = [MLBehaviorAnalytics]::new(
                $item.enabled,
                $item.alertRuleTemplateName
            )

            $body = [AlertRule]::new( $item.name, $item.etag, $bodyAlertProp, $item.Id, 'MLBehaviorAnalytics')

            try {
                $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json -Depth 10 -EnumsAsStrings)
                $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue $($result.StatusDescription) -Force
                $body.Properties | Add-Member -NotePropertyName Kind -NotePropertyValue "MLBehaviorAnalytics" -Force

                $return += $body.Properties
            }
            catch {
                $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue "failed" -Force
                $body.Properties | Add-Member -NotePropertyName Kind -NotePropertyValue "MLBehaviorAnalytics" -Force
                $return += $body.Properties

                Write-Verbose $_
                Write-Verbose "Unable to invoke webrequest for rule $($item.displayName) with error message: $($_.Exception.Message)" -ErrorAction Continue
            }
        }

        <#
            MicrosoftSecurityIncidentCreation
        #>
        foreach ($item in $rules.MicrosoftSecurityIncidentCreation) {
            Write-Verbose "Rule type is Microsoft Security"

            $guid = (New-Guid).Guid

            $content = $allRulesContent | Where-Object {$_.kind -eq 'MicrosoftSecurityIncidentCreation' -and $_.displayName -eq $item.displayName}

            Write-Verbose -Message "Get rule $($item.description)"
            $content = Get-AzSentinelAlertRule @arguments -RuleName $($item.displayName) -ErrorAction SilentlyContinue

            if ($content) {
                Write-Verbose "Rule $($item.displayName) exists in Azure Sentinel"

                $item | Add-Member -NotePropertyName name -NotePropertyValue $content.name -Force
                $item | Add-Member -NotePropertyName etag -NotePropertyValue $content.etag -Force
                $item | Add-Member -NotePropertyName Id -NotePropertyValue $content.id -Force

                $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/alertRules/$($content.name)?api-version=2019-01-01-preview"
            }
            else {
                Write-Verbose -Message "Rule $($item.displayName) doesn't exist in Azure Sentinel"

                $item | Add-Member -NotePropertyName name -NotePropertyValue $guid -Force
                $item | Add-Member -NotePropertyName etag -NotePropertyValue $null -Force
                $item | Add-Member -NotePropertyName Id -NotePropertyValue "$script:Workspace/providers/Microsoft.SecurityInsights/alertRules/$guid" -Force
                $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/alertRules/$($guid)?api-version=2019-01-01-preview"
            }

            $bodyAlertProp = [MicrosoftSecurityIncidentCreation]::new(
                $item.displayName,
                $item.description,
                $item.enabled,
                $item.productFilter,
                $item.severitiesFilter,
                $item.displayNamesFilter
            )

            $body = [AlertRule]::new( $item.name, $item.etag, $bodyAlertProp, $item.Id, 'MicrosoftSecurityIncidentCreation')

            try {
                $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json -Depth 10 -EnumsAsStrings)

                $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue $($result.StatusDescription) -Force
                $body.Properties | Add-Member -NotePropertyName Kind -NotePropertyValue "MicrosoftSecurityIncidentCreation" -Force
                $return += $body.Properties
            }
            catch {
                $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue "failed" -Force
                $body.Properties | Add-Member -NotePropertyName Kind -NotePropertyValue "MicrosoftSecurityIncidentCreation" -Force
                $return += $body.Properties

                Write-Verbose $_
                Write-Verbose "Unable to invoke webrequest for rule $($item.displayName) with error message: $($_.Exception.Message)" -ErrorAction Continue
            }
        }

        return $return
    }
}

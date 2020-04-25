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
        #Get-LogAnalyticWorkspace @arguments

        if ($SettingsFile.Extension -eq '.json') {
            try {
                $analytics = (Get-Content $SettingsFile -Raw | ConvertFrom-Json -ErrorAction Stop).analytics
                Write-Verbose -Message "Found $($analytics.count) rules"
            }
            catch {
                Write-Verbose $_
                Write-Error -Message 'Unable to convert JSON file' -ErrorAction Stop
            }
        }
        elseif ($SettingsFile.Extension -in '.yaml', '.yml') {
            try {
                $analytics = [pscustomobject](Get-Content $SettingsFile -Raw | ConvertFrom-Yaml -ErrorAction Stop)
                $analytics | Add-Member -MemberType NoteProperty -Name DisplayName -Value $analytics.name
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

        foreach ($item in $analytics) {
            Write-Verbose -Message "Started with rule: $($item.displayName)"

            $guid = (New-Guid).Guid

            try {
                Write-Verbose -Message "Get rule $($item.description)"
                $content = Get-AzSentinelAlertRule @arguments -RuleName $($item.displayName) -ErrorAction SilentlyContinue

                if ($content) {
                    Write-Output "Rule $($item.displayName) exists in Azure Sentinel"

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
            }
            catch {
                Write-Verbose $_
                Write-Error "Unable to connect to APi to get Analytic rules with message: $($_.Exception.Message)" -ErrorAction Stop
            }

            try {
                if ($item.incidentConfiguration) {
                    $groupingConfiguration = [groupingConfiguration]::new(
                        $item.incidentConfiguration.groupingConfiguration.enabled,
                        $item.incidentConfiguration.groupingConfiguration.reopenClosedIncident,
                        $item.incidentConfiguration.groupingConfiguration.lookbackDuration,
                        $item.incidentConfiguration.groupingConfiguration.entitiesMatchingMethod,
                        $item.incidentConfiguration.groupingConfiguration.groupByEntities
                    )

                    $IncidentConfiguration = [IncidentConfiguration]::new(
                        $item.incidentConfiguration.createIncident,
                        $groupingConfiguration
                    )
                }

                $bodyAlertProp = [AlertProp]::new(
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
                    $IncidentConfiguration

                )
                $body = [AlertRule]::new( $item.name, $item.etag, $bodyAlertProp, $item.Id)

            }
            catch {
                Write-Error "Unable to initiate class with error: $($_.Exception.Message)" -ErrorAction Continue
            }

            if ($content) {
                if ($item.playbookName) {
                    $compareResult = Compare-Policy -ReferenceTemplate ($content | Select-Object * -ExcludeProperty lastModifiedUtc, alertRuleTemplateName, name, etag, id) -DifferenceTemplate ($body.Properties | Select-Object * -ExcludeProperty name)
                }
                else {
                    $compareResult = Compare-Policy -ReferenceTemplate ($content | Select-Object * -ExcludeProperty lastModifiedUtc, alertRuleTemplateName, name, etag, id, PlaybookName) -DifferenceTemplate ($body.Properties | Select-Object * -ExcludeProperty name, PlaybookName)
                }
                if ($compareResult) {
                    Write-Output "Found Differences for rule: $($item.displayName)"
                    Write-Output ($compareResult | Format-Table | Out-String)

                    if ($PSCmdlet.ShouldProcess("Do you want to update profile: $($body.Properties.DisplayName)")) {
                        try {
                            $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | Select-Object * -ExcludeProperty Properties.PlaybookName | ConvertTo-Json -EnumsAsStrings)

                            if (($compareResult | Where-Object PropertyName -eq "playbookName").DiffValue) {
                                New-AzSentinelAlertRuleAction @arguments -PlayBookName ($body.Properties.playbookName) -RuleId $($body.Name)
                            }
                            elseif (($compareResult | Where-Object PropertyName -eq "playbookName").RefValue) {
                                Remove-AzSentinelAlertRuleAction @arguments -RuleId $($body.Name) -Confirm:$false
                            }
                            else {
                                #nothing
                            }
                            Write-Output "Successfully updated rule: $($item.displayName) with status: $($result.StatusDescription)"
                            Write-Output ($body.Properties | Format-List | Format-Table | Out-String)
                        }
                        catch {
                            Write-Verbose $_
                            Write-Error "Unable to invoke webrequest with error message: $($_.Exception.Message)" -ErrorAction Continue
                        }
                    }
                    else {
                        Write-Output "No change have been made for rule $($item.displayName), deployment aborted"
                    }
                }
                else {
                    Write-Output "Rule $($item.displayName) is compliance, nothing to do"
                    Write-Output ($body.Properties | Format-List | Format-Table | Out-String)
                }
            }
            else {
                Write-Verbose "Creating new rule: $($item.displayName)"

                try {
                    $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | Select-Object * -ExcludeProperty Properties.PlaybookName | ConvertTo-Json -EnumsAsStrings)
                    if ($body.Properties.playbookName) {
                        New-AzSentinelAlertRuleAction @arguments -PlayBookName $($body.Properties.playbookName) -RuleId $($body.Properties.Name) -confirm:$false
                    }

                    Write-Output "Successfully created rule: $($item.displayName) with status: $($result.StatusDescription)"
                    Write-Output ($body.Properties | Format-List | Format-Table | Out-String)
                }
                catch {
                    Write-Verbose $_
                    Write-Error "Unable to invoke webrequest with error message: $($_.Exception.Message)" -ErrorAction Continue
                }
            }
        }
    }
}

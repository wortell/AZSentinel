#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Get-AzSentinelAlertRule {
    <#
      .SYNOPSIS
      Get Azure Sentinel Alert Rules
      .DESCRIPTION
      With this function you can get the configuration of the Azure Sentinel Alert rule from Azure Sentinel
      .PARAMETER SubscriptionId
      Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
      .PARAMETER WorkspaceName
      Enter the Workspace name
      .PARAMETER RuleName
      Enter the name of the Alert rule
      .PARAMETER Kind
      The alert rule kind
      .PARAMETER LastModified
      Filter for rules modified after this date/time
      .PARAMETER SkipPlaybook
      Use SkipPlaybook switch to only return the rule properties, this skips the Playbook resolve step.
      .EXAMPLE
      Get-AzSentinelAlertRule -WorkspaceName "" -RuleName "",""
      In this example you can get configuration of multiple alert rules in once
      .EXAMPLE
      Get-AzSentinelAlertRule -SubscriptionId "" -WorkspaceName "" -LastModified 2020-09-21
      In this example you can get configuration of multiple alert rules only if modified after the 21st September 2020. The datetime must be in ISO8601 format.
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
        [string[]]$RuleName,

        [Parameter(Mandatory = $false,
            ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Kind[]]$Kind,

        [Parameter(Mandatory = $false,
            ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [DateTime]$LastModified,

        [Parameter(Mandatory = $false,
            ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [switch]$SkipPlaybook
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
            Get-LogAnalyticWorkspace @arguments -ErrorAction Stop
        }
        catch {
            Write-Error $_.Exception.Message
            break
        }

        $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/alertRules?api-version=2020-01-01"
        Write-Verbose -Message "Using URI: $($uri)"

        try {
            $alertRules = Invoke-RestMethod -Uri $uri -Method Get -Headers $script:authHeader
        }
        catch {
            Write-Verbose $_
            Write-Error "Unable to get alert rules with error code: $($_.Exception.Message)" -ErrorAction Stop
        }

        $return = @()
        if ($alertRules.value -and $LastModified) {
            Write-Verbose "Filtering for rules modified after $LastModified"
            $alertRules.value = $alertRules.value | Where-Object { $_.properties.lastModifiedUtc -gt $LastModified }
        }
        if ($alertRules.value) {
            Write-Verbose "Found $($alertRules.value.count) Alert rules"

            if ($RuleName.Count -ge 1) {
                foreach ($rule in $RuleName) {
                    $alertRules.value | Where-Object { $_.properties.displayName -eq $rule } | ForEach-Object {

                        $_.properties | Add-Member -NotePropertyName name -NotePropertyValue $_.name -Force
                        $_.properties | Add-Member -NotePropertyName etag -NotePropertyValue $_.etag -Force
                        $_.properties | Add-Member -NotePropertyName id -NotePropertyValue $_.id -Force
                        $_.properties | Add-Member -NotePropertyName kind -NotePropertyValue $_.kind -Force

                        # Updating incidentConfiguration output to match JSON input
                        if ($_.properties.kind -eq 'Scheduled'){
                            $_.properties | Add-Member -NotePropertyName createIncident -NotePropertyValue $_.properties.incidentConfiguration.createIncident -Force
                            $_.properties | Add-Member -NotePropertyName groupingConfiguration -NotePropertyValue $_.properties.incidentConfiguration.groupingConfiguration -Force
                            $_.properties.PSObject.Properties.Remove('incidentConfiguration')
                        }

                        if (! $SkipPlaybook) {

                            $playbook = Get-AzSentinelAlertRuleAction @arguments -RuleId $_.name

                            if ($playbook) {
                                $playbookName = ($playbook.properties.logicAppResourceId).Split('/')[-1]
                            }
                            else {
                                $playbookName = ""
                            }

                            $_.properties | Add-Member -NotePropertyName playbookName -NotePropertyValue $playbookName -Force
                        }

                        $return += $_.properties
                    }
                }
                return $return
            }
            elseif ($Kind.Count -ge 1) {
                foreach ($rule in $Kind) {
                    $alertRules.value | Where-Object { $_.Kind -eq $rule } | ForEach-Object {

                        $_.properties | Add-Member -NotePropertyName name -NotePropertyValue $_.name -Force
                        $_.properties | Add-Member -NotePropertyName etag -NotePropertyValue $_.etag -Force
                        $_.properties | Add-Member -NotePropertyName id -NotePropertyValue $_.id -Force
                        $_.properties | Add-Member -NotePropertyName kind -NotePropertyValue $_.kind -Force

                        # Updating incidentConfiguration output to match JSON input
                        if ($_.properties.kind -eq 'Scheduled'){
                            $_.properties | Add-Member -NotePropertyName createIncident -NotePropertyValue $_.properties.incidentConfiguration.createIncident -Force
                            $_.properties | Add-Member -NotePropertyName groupingConfiguration -NotePropertyValue $_.properties.incidentConfiguration.groupingConfiguration -Force
                            $_.properties.PSObject.Properties.Remove('incidentConfiguration')
                        }

                        if (! $SkipPlaybook) {

                            $playbook = Get-AzSentinelAlertRuleAction @arguments -RuleId $_.name

                            if ($playbook) {
                                $playbookName = ($playbook.properties.logicAppResourceId).Split('/')[-1]
                            }
                            else {
                                $playbookName = ""
                            }

                            $_.properties | Add-Member -NotePropertyName playbookName -NotePropertyValue $playbookName -Force
                        }

                        $return += $_.properties
                    }
                }
                return $return
            }
            else {
                $alertRules.value | ForEach-Object {

                    $_.properties | Add-Member -NotePropertyName name -NotePropertyValue $_.name -Force
                    $_.properties | Add-Member -NotePropertyName id -NotePropertyValue $_.id -Force
                    $_.properties | Add-Member -NotePropertyName kind -NotePropertyValue $_.kind -Force

                    # Updating incidentConfiguration output to match JSON input
                    if ($_.properties.kind -eq 'Scheduled'){
                        $_.properties | Add-Member -NotePropertyName createIncident -NotePropertyValue $_.properties.incidentConfiguration.createIncident -Force
                        $_.properties | Add-Member -NotePropertyName groupingConfiguration -NotePropertyValue $_.properties.incidentConfiguration.groupingConfiguration -Force
                        $_.properties.PSObject.Properties.Remove('incidentConfiguration')
                    }

                    if (! $SkipPlaybook) {

                        $playbook = Get-AzSentinelAlertRuleAction @arguments -RuleId $_.name

                        if ($playbook) {
                            $playbookName = ($playbook.properties.logicAppResourceId).Split('/')[-1]
                        }
                        else {
                            $playbookName = ""
                        }

                        $_.properties | Add-Member -NotePropertyName playbookName -NotePropertyValue $playbookName -Force
                    }

                    $return += $_.properties
                }
                return $return
            }
        }
        else {
            Write-Verbose "No rules found on $($WorkspaceName)"
        }
    }
}

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
      .EXAMPLE
      Get-AzSentinelAlertRule -WorkspaceName "" -RuleName "",""
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
        Get-LogAnalyticWorkspace @arguments

        $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/alertRules?api-version=2019-01-01-preview"
        Write-Verbose -Message "Using URI: $($uri)"

        try {
            $alertRules = Invoke-RestMethod -Uri $uri -Method Get -Headers $script:authHeader
        }
        catch {
            Write-Verbose $_
            Write-Error "Unable to get alert rules with error code: $($_.Exception.Message)" -ErrorAction Stop
        }

        $return = @()

        if ($alertRules.value) {
            Write-Verbose "Found $($alertRules.value.count) Alert rules"

            if ($RuleName.Count -ge 1) {
                foreach ($rule in $RuleName) {
                    [PSCustomObject]$temp = $alertRules.value | Where-Object { $_.properties.displayName -eq $rule }
                    if ($null -ne $temp) {

                        $playbook = Get-AzSentinelAlertRuleAction @arguments -RuleId ($temp.name)

                        if ($playbook) {
                            $playbookName = ($playbook.properties.logicAppResourceId).Split('/')[-1]
                        }
                        else {
                            $playbookName = ""
                        }

                        $temp.properties | Add-Member -NotePropertyName name -NotePropertyValue $temp.name -Force
                        $temp.properties | Add-Member -NotePropertyName etag -NotePropertyValue $temp.etag -Force
                        $temp.properties | Add-Member -NotePropertyName id -NotePropertyValue $temp.id -Force
                        $temp.properties | Add-Member -NotePropertyName playbookName -NotePropertyValue $playbookName -Force

                        $return += $temp.properties
                    }
                    else {
                        Write-Error "Unable to find Rule: $rule"
                    }
                }
                return $return
            }
            else {
                $alertRules.value | ForEach-Object {
                    $playbook = Get-AzSentinelAlertRuleAction @arguments -RuleId ($_.name)

                    if ($playbook) {
                        $playbookName = ($playbook.properties.logicAppResourceId).Split('/')[-1]
                    }
                    else {
                        $playbookName = ""
                    }
                    $_.properties | Add-Member -NotePropertyName name -NotePropertyValue $_.name -Force
                    $_.properties | Add-Member -NotePropertyName playbookName -NotePropertyValue $playbookName -Force

                    return $_.properties
                }
            }
        }
        else {
            Write-Warning "No rules found on $($WorkspaceName)"
        }
    }
}

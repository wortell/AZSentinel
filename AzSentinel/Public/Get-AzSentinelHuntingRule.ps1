#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -module @{ModuleNAme = 'powershell-yaml'; ModuleVersion = '0.4.0'}
#requires -version 6.0

using module Az.Accounts

function Get-AzSentinelHuntingRule {
    <#
    .SYNOPSIS
    Get Azure Sentinel Hunting rule
    .DESCRIPTION
    With this function you can get the configuration of the Azure Sentinel Hunting rule from Azure Sentinel
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER WorkspaceName
    Enter the Workspace name
    .PARAMETER RuleName
    Enter the name of the Hunting rule name
    .EXAMPLE
    Get-AzSentinelHuntingRule -WorkspaceName "" -RuleName "",""
    In this example you can get configuration of multiple Huntinh rules
    .EXAMPLE
    Get-AzSentinelHuntingRule -WorkspaceName ""
    In this example you can get configuration of all the Hunting rules in once
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

        [Parameter(Mandatory = $false)]
        [validateset("HuntingQueries", "GeneralExploration", "LogManagement")]
        [string]$Filter
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

        $uri = "$script:baseUri/savedSearches?api-version=2017-04-26-preview"

        Write-Verbose -Message "Using URI: $($uri)"
        $alertRules = Invoke-webrequest -Uri $uri -Method get -Headers $script:authHeader
        Write-Verbose "Found $((($alertRules.Content | ConvertFrom-Json).value).count) Alert rules"
        $return = @()

        if ($alertRules) {
            if ($RuleName.Count -ge 1) {
                foreach ($rule in $RuleName) {
                    [PSCustomObject]$temp = ($alertRules.Content | ConvertFrom-Json).value | Where-Object {$_.properties.displayName -eq $rule}
                    if ($null -ne $temp) {
                        $temp.properties | Add-Member -NotePropertyName name -NotePropertyValue $temp.name -Force
                        $temp.properties | Add-Member -NotePropertyName id -NotePropertyValue $temp.id -Force
                        $temp.properties | Add-Member -NotePropertyName etag -NotePropertyValue $temp.etag -Force

                        $return += $temp.Properties
                    }
                    else {
                        Write-Warning "Unable to find Rule: $rule"
                    }
                }
                return $return
            }
            else {
                ($alertRules.Content | ConvertFrom-Json).value | ForEach-Object {
                    $_.properties | Add-Member -NotePropertyName name -NotePropertyValue $_.name -Force
                    $_.properties | Add-Member -NotePropertyName id -NotePropertyValue $_.id -Force
                    $_.properties | Add-Member -NotePropertyName etag -NotePropertyValue $_.etag -Force
                    return $_.properties
                }
            }
        }
        else {
            Write-Warning "No rules found on $($WorkspaceName)"
        }
    }
}

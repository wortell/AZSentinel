#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

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
    .PARAMETER Filter
    Select which type of Hunting rules you want to see. Option: HuntingQueries, GeneralExploration, LogManagement
    .EXAMPLE
    Get-AzSentinelHuntingRule -WorkspaceName "" -RuleName "",""
    In this example you can get configuration of multiple Hunting rules
    .EXAMPLE
    Get-AzSentinelHuntingRule -WorkspaceName ""
    In this example you can get a list of all the Hunting rules in once
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


        try {
            if ($Filter) {
                $huntingRules = (Invoke-RestMethod -Uri $uri -Method Get -Headers $script:authHeader) | Where-Object $_.Category -eq $Filter
            }
            else {
                $huntingRules = (Invoke-RestMethod -Uri $uri -Method Get -Headers $script:authHeader)

            }
        }
        catch {
            Write-Verbose $_
            Write-Error "Unable to get hunting rules with error code: $($_.Exception.Message)" -ErrorAction Stop
        }

        $return = @()

        if ($huntingRules.value) {
            Write-Verbose "Found $($huntingRules.value.count) hunting rules"
            if ($RuleName.Count -ge 1) {
                foreach ($rule in $RuleName) {
                    [PSCustomObject]$temp = $huntingRules.value | Where-Object { $_.displayName -eq $rule }
                    if ($null -ne $temp) {
                        $temp.properties | Add-Member -NotePropertyName name -NotePropertyValue $temp.name -Force
                        $temp.properties | Add-Member -NotePropertyName id -NotePropertyValue $temp.id -Force
                        $temp.properties | Add-Member -NotePropertyName etag -NotePropertyValue $temp.etag -Force

                        $return += $temp.Properties
                    }
                    else {
                        Write-Warning "Unable to find hunting rule: $rule"
                    }
                }
                return $return
            }
            else {
                $huntingRules.value | ForEach-Object {
                    $_.properties | Add-Member -NotePropertyName name -NotePropertyValue $_.name -Force
                    $_.properties | Add-Member -NotePropertyName id -NotePropertyValue $_.id -Force
                    $_.properties | Add-Member -NotePropertyName etag -NotePropertyValue $_.etag -Force
                    return $_.properties
                }
            }
        }
        else {
            Write-Warning "No hunting rules found on $($WorkspaceName)"
        }
    }
}

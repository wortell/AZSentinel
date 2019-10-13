#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -module @{ModuleNAme = 'powershell-yaml'; ModuleVersion = '0.4.0'}
#requires -version 6.0

using module Az.Accounts

function Get-AzSentinelIncident {
    <#
    .SYNOPSIS
    Get Azure Sentinel Incident
    .DESCRIPTION
    With this function you can get a list of open incidents from Azure Sentinel.
    You can can also filter to Incident with speciefiek case namber or Case name
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER WorkspaceName
    Enter the Workspace name
    .PARAMETER IncidentName
    Enter incident name, this is the same name as the alert rule that triggered the incident
    .PARAMETER CaseNumber
    Enter the case number to get specfiek details of a open case
    .EXAMPLE
    Get-AzSentinelIncident -WorkspaceName ""
    Get a list of all open Incidents
    .EXAMPLE
    Get-AzSentinelIncident -WorkspaceName "" -CaseNumber
    Get information of a specifiek incident with providing the casenumber
    .EXAMPLE
    Get-AzSentinelIncident -WorkspaceName "" -IncidentName "",""
    Get information of one or more incidents with providing a incident name, this is the name of the alert rule that triggered the incident
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
        [string[]]$IncidentName,

        [Parameter(Mandatory = $false,
            ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [int[]]$CaseNumber
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

        $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/Cases?api-version=2019-01-01-preview"
        Write-Verbose -Message "Using URI: $($uri)"
        $incident = Invoke-webrequest -Uri $uri -Method get -Headers $script:authHeader
        Write-Verbose "Found $((($incident.Content | ConvertFrom-Json).value).count) incidents"
        $return = @()

        if ($incident) {
            if ($IncidentName.Count -ge 1) {
                foreach ($rule in $IncidentName) {
                    [PSCustomObject]$temp = ($incident.Content | ConvertFrom-Json).value | Where-Object { $_.properties.title -eq $rule }
                    if ($null -ne $temp) {
                        $return += $temp.properties
                    }
                    else {
                        Write-Error "Unable to find incident: $rule"
                    }
                }
                return $return
            }
            elseif ($CaseNumber.Count -ge 1) {
                foreach ($rule in $CaseNumber) {
                    [PSCustomObject]$temp = ($incident.Content | ConvertFrom-Json).value | Where-Object { $_.properties.caseNumber -eq $rule }
                    if ($null -ne $temp) {
                        $return += $temp.properties
                    }
                    else {
                        Write-Error "Unable to find incident: $rule"
                    }
                }
                return $return
            }
            else {
                ($incident.Content | ConvertFrom-Json).value | ForEach-Object {
                    return $_.properties
                }
            }
        }
        else {
            Write-Warning "No incident found on $($WorkspaceName)"
        }
    }
}

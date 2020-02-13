#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Update-AzSentinelIncident {
    <#
    .SYNOPSIS
    Update Azure Sentinel Incident
    .DESCRIPTION
    With this function you can update existing Azure Sentinel Incident.
    You can can also filter to Incident with speciefiek case namber or Case name
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER WorkspaceName
    Enter the Workspace name
    .PARAMETER CaseNumber
    Enter the case number to get specfiek details of a open case
    .EXAMPLE
    Update-AzSentinelIncident -WorkspaceName ""
    Get a list of all open Incidents
    .EXAMPLE
    Update-AzSentinelIncident -WorkspaceName '' -CaseNumber 42293 -Labels "NewLabel"
    Update incident with ann Label
    .EXAMPLE
    Update-AzSentinelIncident -WorkspaceName -CaseNumber 42293 -Status Closed -CloseReason FalsePositive -ClosedReasonText "Your input"
    Close a Incidnet using status Closed, when status closed is selected then CloseReason and ClosedReasonText prperty are required to be filled in
    #>

    param (
        [Parameter(Mandatory = $false,
            ParameterSetName = "Sub")]
        [ValidateNotNullOrEmpty()]
        [string] $SubscriptionId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceName,

        [Parameter(Mandatory,
            ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [int]$CaseNumber,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Severity,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Status]$Status,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Comment,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Labels,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [CloseReason]$CloseReason,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$ClosedReasonText
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
        Write-Verbose -Message "Using URI: $($uri)"

        try {
            $incident = Get-AzSentinelIncident @arguments -CaseNumber $CaseNumber
        }
        catch {
            Write-Verbose $_
            Write-Error "Unable to get incidents with error code: $($_.Exception.Message)" -ErrorAction Stop
        }
        if ($incident) {
            if ($Comment) {
                $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/Cases/$($incident.name)/comments/$(New-Guid)?api-version=2019-01-01-preview"
                $body = @{
                    "properties" = @{
                        "message" = $Comment
                    }
                }
            }
            else {
                $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/Cases/$($incident.name)?api-version=2019-01-01-preview"
                $LabelsUnique = $incident.labels + $Labels | Select-Object -Unique
                $body = @{
                    "etag"       = $($incident.etag)
                    "properties" = @{
                        "caseNumber"                               = $CaseNumber
                        "createdTimeUtc"                           = $($incident.incidentcreatedTimeUtc)
                        "endTimeUtc"                               = $($incident.endTimeUtc)
                        "lastUpdatedTimeUtc"                       = $($incident.lastUpdatedTimeUtc)
                        "lastComment"                              = ""
                        "totalComments"                            = 0
                        "metrics"                                  = @{ }
                        [pscustomobject]"relatedAlertIds"          = @(
                        )
                        [pscustomobject]"relatedAlertProductNames" = @(
                        )
                        "severity"                                 = if ($Severity) { $Severity } else { $incident.severity }
                        "startTimeUtc"                             = $($incident.startTimeUtc)
                        "status"                                   = if ($Status) { $Status } else { $incident.status }
                        "closeReason"                              = if ($Status -eq 'Closed') { if ($null -ne [CloseReason]$CloseReason) { $CloseReason } else { Write-Error "No Close Reasen provided" -ErrorAction Stop } } else { $null }
                        "closedReasonText"                         = if ($Status -eq 'Closed') { if ($ClosedReasonText) { $ClosedReasonText } else { Write-Error 'No closed comment provided' } } else { $null }
                        [pscustomobject]"labels"                   = @( $LabelsUnique)
                        "title"                                    = $($incident.title)
                        "description"                              = ""
                        "firstAlertTimeGenerated"                  = ""
                        "lastAlertTimeGenerated"                   = ""
                        "owner"                                    = @{
                            "name"     = $null
                            "email"    = $null
                            "objectId" = $null
                        }
                    }
                }
            }

            Write-Host "Found incident with case number: $($incident.caseNumber)"

            try {
                $return = Invoke-WebRequest -Uri $uri -Method Put -Body ($body | ConvertTo-Json -Depth 99 -EnumsAsStrings) -Headers $script:authHeader

                Write-Host "Successfully updated Incident $($incident.caseNumber) with status $($return.StatusDescription)"
            }
            catch {
                Write-Verbose $_
                Write-Error "Unable to update Incident $($incident.caseNumber) with error message $($_.Exception.Message)"
            }
        }
        else {
            Write-Warning "No incident found on $($WorkspaceName)"
        }
    }
}

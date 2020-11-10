#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Update-AzSentinelIncident {
    <#
    .SYNOPSIS
    Update Azure Sentinel Incident
    .DESCRIPTION
    With this function you can update existing Azure Sentinel Incident.
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER WorkspaceName
    Enter the Workspace name
    .PARAMETER CaseNumber
    Enter the case number to get specfiek details of a open case
    .PARAMETER Severity
    Enter the Severity, you can choose from Medium, High, Low and Informational
    .PARAMETER Status
    Enter the Status of the incident, you can choose from New, InProgress and Closed
    .PARAMETER Comment
    Enter Comment tekst to add comment to the incident
    .PARAMETER Labels
    Add Lebels to the incident, current configured Labels will be added to the existing Labels
    .PARAMETER CloseReason
    When Status is equil to Closed, CloseReason is required. You can select from: TruePositive, FalsePositive
    .PARAMETER ClosedReasonText
    When Status is equil to Closed, ClosedReasonText is required to be filled in.
    .EXAMPLE
    Update-AzSentinelIncident -WorkspaceName ""
    Get a list of all open Incidents
    .EXAMPLE
    Update-AzSentinelIncident -WorkspaceName '' -CaseNumber 42291 -Labels "NewLabel"
    Add a new Label to list of Labels for a Incident
    .EXAMPLE
    Update-AzSentinelIncident -WorkspaceName '' -CaseNumber 42293 -Status Closed -CloseReason FalsePositive -ClosedReasonText "Your input"
    Close the Incidnet using status Closed, when status closed is selected then CloseReason and ClosedReasonText prperty are required to be filled in
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
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
        [string]$ClosedReasonText,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Description
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
            $incident = Get-AzSentinelIncident @arguments -CaseNumber $CaseNumber -ErrorAction Stop
        }
        catch {
            Write-Error $_.Exception.Message
            break
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
                        "caseNumber"               = $CaseNumber
                        "createdTimeUtc"           = $($incident.incidentcreatedTimeUtc)
                        "endTimeUtc"               = $($incident.endTimeUtc)
                        "lastUpdatedTimeUtc"       = $($incident.lastUpdatedTimeUtc)
                        "lastComment"              = ""
                        "totalComments"            = $incident.TotalComments
                        "metrics"                  = $incident.Metrics
                        "relatedAlertIds"          = $incident.RelatedAlertIds
                        "relatedAlertProductNames" = $incident.RelatedAlertProductNames
                        "severity"                 = if ($Severity) { $Severity } else { $incident.severity }
                        "startTimeUtc"             = $($incident.startTimeUtc)
                        "status"                   = if ($Status) { $Status } else { $incident.status }
                        "closeReason"              = if ($Status -eq 'Closed') { if ($null -ne [CloseReason]$CloseReason) { $CloseReason } else { Write-Error "No close reason provided" -ErrorAction Stop } } else { $null }
                        "closedReasonText"         = if ($Status -eq 'Closed') { if ($ClosedReasonText) { $ClosedReasonText } else { Write-Error 'No closed comment provided' } } else { $null }
                        [pscustomobject]"labels"   = @( $LabelsUnique)
                        "title"                    = $($incident.title)
                        "description"              = if ($Description) { $Description } else { $incident.Description }
                        "firstAlertTimeGenerated"  = $incident.FirstAlertTimeGenerated
                        "lastAlertTimeGenerated"   = $incident.LastAlertTimeGenerated
                        "owner"                    = @{
                            "name"     = $incident.Owner.Name
                            "email"    = $incident.Owner.Email
                            "objectId" = $incident.Owner.ObjectId
                        }
                    }
                }
            }

            Write-Output "Found incident with case number: $($incident.caseNumber)"

            if ($PSCmdlet.ShouldProcess("Do you want to update Incident: $($body.Properties.DisplayName)")) {
                try {
                    $return = Invoke-WebRequest -Uri $uri -Method Put -Body ($body | ConvertTo-Json -Depth 99 -EnumsAsStrings) -Headers $script:authHeader
                    return ($return.Content | ConvertFrom-Json).properties
                }
                catch {
                    $return = $_.Exception.Message
                    Write-Verbose $_
                    Write-Error "Unable to update Incident $($incident.caseNumber) with error message $return"
                    return $return
                }
            }
            else {
                Write-Output "No change have been made for Incident $($incident.caseNumber), update aborted"
            }
        }
    }
}

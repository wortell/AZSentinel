#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Add-AzSentinelIncidentComment {
    <#
    .SYNOPSIS
    Add Azure Sentinel Incident comment
    .DESCRIPTION
    With this function you can add comment to existing Azure Sentinel Incident.
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER WorkspaceName
    Enter the Workspace name
    .PARAMETER Name
    Enter the name of the incidnet in GUID format
    .PARAMETER CaseNumber
    Enter the case number to get specfiek details of a open case
    .PARAMETER Comment
    Enter Comment tekst to add comment to the incident
    .EXAMPLE
    Add-AzSentinelIncidentComment -WorkspaceName "" CaseNumber "" -Comment
    Add a comment to existing incidnet
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

        [Parameter(Mandatory = $false,
            ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [guid]$Name,

        [Parameter(Mandatory = $false,
            ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [int]$CaseNumber,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Comment
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

        if ($CaseNumber) {
            $incident = Get-AzSentinelIncident @arguments -CaseNumber $CaseNumber -All
        }
        elseif ($Name) {
            $incident = Get-AzSentinelIncident @arguments -Name $Name
        }
        else {
            Write-Error "Both CaseNumber and Name are empty" -ErrorAction Stop
        }

        if ($incident) {
            $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/Cases/$($incident.name)/comments/$(New-Guid)?api-version=2019-01-01-preview"
            $body = @{
                "properties" = @{
                    "message" = $Comment
                }
            }

            Write-Verbose "Found incident with case number: $($incident.caseNumber)"

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
    }
}

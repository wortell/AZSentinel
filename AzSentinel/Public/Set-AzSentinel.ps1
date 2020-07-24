#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Set-AzSentinel {
    <#
    .SYNOPSIS
    Enable Azure Sentinel
    .DESCRIPTION
    This function enables Azure Sentinel on a existing Workspace
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER WorkspaceName
    Enter the Workspace name
    .EXAMPLE
    Set-AzSentinel -WorkspaceName ""
    This example will enable Azure Sentinel for the provided workspace
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $false,
            ParameterSetName = "Sub")]
        [ValidateNotNullOrEmpty()]
        [string] $SubscriptionId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceName

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
        $workspaceResult = Get-LogAnalyticWorkspace @arguments -FullObject

        # Variables
        $errorResult = ''

        if ($workspaceResult.properties.provisioningState -eq 'Succeeded') {
            $body = @{
                'id'         = ''
                'etag'       = ''
                'name'       = ''
                'type'       = ''
                'location'   = $workspaceResult.location
                'properties' = @{
                    'workspaceResourceId' = $workspaceResult.id
                }
                'plan'       = @{
                    'name'          = 'SecurityInsights($workspace)'
                    'publisher'     = 'Microsoft'
                    'product'       = 'OMSGallery/SecurityInsights'
                    'promotionCode' = ''
                }
            }
            $uri = "$(($Script:baseUri).Split('microsoft.operationalinsights')[0])Microsoft.OperationsManagement/solutions/SecurityInsights($WorkspaceName)?api-version=2015-11-01-preview"

            try {
                $solutionResult = Invoke-webrequest -Uri $uri -Method Get -Headers $script:authHeader
                Write-Output "Azure Sentinel is already enabled on $WorkspaceName and status is: $($solutionResult.StatusDescription)"
            }
            catch {
                $errorReturn = $_
                $errorResult = ($errorReturn | ConvertFrom-Json ).error
                if ($errorResult.Code -eq 'ResourceNotFound') {
                    Write-Output "Azure Sentinetal is not enabled on workspace: $($WorkspaceName)"
                    try {
                        if ($PSCmdlet.ShouldProcess("Do you want to enable Sentinel for Workspace: $workspace")) {
                            $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json)
                            Write-Output "Successfully enabled Sentinel on workspae: $WorkspaceName with result code $($result.StatusDescription)"
                        }
                        else {
                            Write-Output "No change have been made for rule $WorkspaceName, deployment aborted"
                        }
                    }
                    catch {
                        Write-Verbose $_
                        Write-Error "Unable to enable Sentinel on $WorkspaceName with error message: $($_.Exception.Message)"
                    }

                }
                else {
                    Write-Verbose $_
                    Write-Error "Unable to Azure Sentinel with error message: $($_.Exception.Message)" -ErrorAction Stop
                }
            }

        }
        else {
            Write-Error "Workspace $WorkspaceName is currently in $($workspaceResult.properties.provisioningState) status, setup canceled"
        }
    }
}

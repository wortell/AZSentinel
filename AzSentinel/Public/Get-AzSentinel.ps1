#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Get-AzSentinel {
    <#
      .SYNOPSIS
      Get Azure Sentinel Workspace
      .DESCRIPTION
      With this function you can get the configuration of the Azure Sentinel Alert rule from Azure Sentinel
      .PARAMETER SubscriptionId
      Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
      .PARAMETER WorkspaceName
      Enter the Workspace name
      .EXAMPLE
      Get-AzSentinel -WorkspaceName ""
      In this example you can get configuration of multiple alert rules in once
    #>

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
        $workspace = Get-LogAnalyticWorkspace @arguments -FullObject


        if ($workspace) {
            $uri = "$(($Script:baseUri).Split('microsoft.operationalinsights')[0])Microsoft.OperationsManagement/solutions/SecurityInsights($WorkspaceName)?api-version=2015-11-01-preview"

            $solutionResult = Invoke-RestMethod -Uri $uri -Method Get -Headers $script:authHeader
            Write-Output "Azure Sentinel is already enabled on $WorkspaceName and status is: $($solutionResult.StatusDescription)"
            return $solutionResult

        } else {
                Write-Error "no workspace found"
        }
    }
}

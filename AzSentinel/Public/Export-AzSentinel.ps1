function Export-AzSentinel {
    <#
      .SYNOPSIS
      Export Azure Sentinel
      .DESCRIPTION
      With this function you can export Azure Sentinel configuration
      .PARAMETER SubscriptionId
      Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
      .PARAMETER WorkspaceName
      Enter the Workspace name
      .PARAMETER Export
      Enter the name of the Alert rule
      .EXAMPLE
      Export-AzSentinel -WorkspaceName "" -Export "",""
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
        [ExportType[]]$Export
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


        if ($Export -eq 'Analytic') {

        }
        if ($Export -eq 'Hunting') {

        }
    }

}

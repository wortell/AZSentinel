#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Get-AzSentinelDataConnector {
    <#
      .SYNOPSIS
      Get Azure Sentinel Data connector
      .DESCRIPTION
      With this function you can get Azure Sentinel data connectors that are enabled on the workspace
      .PARAMETER SubscriptionId
      Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
      .PARAMETER WorkspaceName
      Enter the Workspace name
      .PARAMETER DataConnectorName
      Enter the Connector ID
      .EXAMPLE
      Get-AzSentinelDataConnector -WorkspaceName ""
      List all  enabled dataconnector
      .EXAMPLE
      Get-AzSentinelDataConnector -WorkspaceName "" -DataConnectorName "",""
      Get specific dataconnectors
    #>

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
        [string[]]$DataConnectorName,

        [Parameter(Mandatory = $false,
            ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [DataSourceName[]]$DataSourceName
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

        try {
            Get-LogAnalyticWorkspace @arguments -ErrorAction Stop
        }
        catch {
            Write-Error $_.Exception.Message
            break
        }

        if ($DataConnectorName) {
            $dataConnectors = @()

            foreach ($item in $DataConnectorName){

                $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/dataConnectors/$($item)?api-version=2020-01-01"

                try {
                    $result = Invoke-RestMethod -Uri $uri -Method Get -Headers $script:authHeader

                    $dataConnectors += $result
                }
                catch {
                    Write-Verbose $_
                    Write-Error "Unable to get alert rules with error code: $($_.Exception.Message)" -ErrorAction Stop
                }
            }
            return $dataConnectors
        }
        elseif ($DataSourceName) {
            $dataSources = @()

            foreach ($dataSource in $DataSourceName){
                $uri = $($script:baseUri)+ "/dataSources?"+'$'+"filter=kind+eq+'"+$dataSource+"'&api-version=2020-08-01"

                try {
                    $result = Invoke-RestMethod -Uri $uri -Method Get -Headers $script:authHeader

                    $dataSources += $result
                }
                catch {
                    Write-Verbose $_
                    Write-Error "Unable to get alert rules with error code: $($_.Exception.Message)" -ErrorAction Stop
                }
            }
            return $dataSources.value
        }
        else {
            $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/dataConnectors?api-version=2020-01-01"

            try {
                $result = Invoke-RestMethod -Uri $uri -Method Get -Headers $script:authHeader
            }
            catch {
                Write-Verbose $_
                Write-Error "Unable to get alert rules with error code: $($_.Exception.Message)" -ErrorAction Stop
            }
            return $result.value
        }
    }
}

#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Get-AzSentinelResourceProvider {
    <#
    .SYNOPSIS
    Get AzSentinelResourceProvider
    .DESCRIPTION
    This function is used to get status of the required resource providers
    .PARAMETER NameSpace
    Enter the name of the namespace without 'Microsoft.'
    .EXAMPLE
    Get-AzSentinelResourceProvider -NameSpace 'OperationsManagement'
    #>
    param (
        [string]$NameSpace
    )

    $uri = "https://management.azure.com/subscriptions/$($script:subscriptionId)/providers/Microsoft.$($NameSpace)?api-version=2019-10-01"

    try {
        $invokeReturn = Invoke-RestMethod -Method Get -Uri $uri -Headers $script:authHeader
        return $invokeReturn
    }
    catch {
        $return = $_.Exception.Message
        Write-Error $return
        return $return
    }
}

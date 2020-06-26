#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2


function Set-AzSentinelResourceProvider {
    <#
    .SYNOPSIS
    Set AzSentinelResourceProvider
    .DESCRIPTION
    This function is enables the required Resource providers
    .PARAMETER NameSpace
    Enter the name of the namespace without 'Microsoft.'
    .EXAMPLE
    Set-AzSentinelResourceProvider -NameSpace 'OperationsManagementOperationsManagement'
    #>

    [OutputType([String])]
    param (
        [string]$NameSpace
    )

    $uri = "https://management.azure.com/subscriptions/$($script:subscriptionId)/providers/Microsoft.$($NameSpace)/register?api-version=2019-10-01"

    try {
        $invokeReturn = Invoke-RestMethod -Method Post -Uri $uri -Headers $script:authHeader
        Write-Verbose $invokeReturn
        do {
            $resourceProviderStatus = Get-AzSentinelResourceProvider -NameSpace $NameSpace
        }
        until ($resourceProviderStatus.registrationState -eq 'Registered')
        $return = "Successfully enabled Microsoft.$($NameSpace) on subscription $($script:subscriptionId). Status:$($resourceProviderStatus.registrationState)"
        return $return
    }
    catch {
        $return = $_.Exception.Message
        Write-Error $return
        return $return
    }
}

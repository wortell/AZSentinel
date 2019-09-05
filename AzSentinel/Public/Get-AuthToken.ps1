#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.0

using module Az.Accounts

function Get-AuthToken {
    <#
    .SYNOPSIS
    Get Authorization Token
    .DESCRIPTION
    This function is used to generate the Authtoken for API Calls
    .EXAMPLE
    Get-AuthToken
    #>

    [cmdletbinding()]
    [OutputType([System.Collections.Hashtable])]
    param (

    )

    try {
        $azContext = Get-AzContext
    }
    catch {
        Write-Verbose $_
        Write-Error "Unable to get AzContext" -ErrorAction Stop
    }

    if ($azContext) {
        $azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
        $profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
        $token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
        $authHeader = @{
            'Content-Type'  = 'application/json'
            'Authorization' = 'Bearer ' + $token.AccessToken
        }

        if ($authHeader) {
            return $authHeader
        }
        else {
            Write-Error "Unable to create Authtoken" -ErrorAction Stop
        }
    }
    else {
        Write-Error "No subscription available, Please use Login-AzAccount to login and select the right subscription" -ErrorAction Stop
    }
}

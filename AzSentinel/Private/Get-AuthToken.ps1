#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Get-AuthToken {
    <#
    .SYNOPSIS
    Get Authorization Token
    .DESCRIPTION
    This function is used to generate the Authtoken for API Calls
    .EXAMPLE
    Get-AuthToken
    #>

    [CmdletBinding()]
    param (

    )

    try {
        $azContext = Get-AzContext

        if ($null -ne $azContext) {
            Write-Verbose -Message "Using Subscription: $($azContext.Subscription.Name) from tenant $($azContext.Tenant.Id)"

            $azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
            $profileClient = [Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient]::new($azProfile)
            $script:accessToken = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
        } else {
            throw 'No subscription available, Please use Connect-AzAccount to login and select the right subscription'
        }
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

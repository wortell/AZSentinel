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

    if ([Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile) {
        Write-Verbose -Message "Using Subscription: $($script:azContext.Subscription.Name) from tenant $($script:azContext.Tenant.Id)"

        $script:subscriptionId =[Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile.DefaultContext.Subscription.Id
        $script:tenantId = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile.DefaultContext.Tenant.Id

        $azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
        $profileClient = [Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient]::new($azProfile)
        $script:accessToken = $profileClient.AcquireAccessToken($script:tenantId)

        $script:authHeader = @{
            'Content-Type' = 'application/json'
            Authorization  = 'Bearer ' + $script:accessToken.AccessToken
        }

    }
    else {
        throw 'No subscription available, Please use Connect-AzAccount to login and select the right subscription'
    }
}

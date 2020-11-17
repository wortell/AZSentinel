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

    $azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile

    Write-Verbose -Message "Using Subscription: $($azProfile.DefaultContext.Subscription.Name) from tenant $($azProfile.DefaultContext.Tenant.Id)"

    $script:subscriptionId = $azProfile.DefaultContext.Subscription.Id
    $script:tenantId = $azProfile.DefaultContext.Tenant.Id

    $profileClient = [Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient]::new($azProfile)
    $script:accessToken = $profileClient.AcquireAccessToken($script:tenantId)

    $script:authHeader = @{
        'Content-Type' = 'application/json'
        Authorization  = 'Bearer ' + $script:accessToken.AccessToken
    }

}

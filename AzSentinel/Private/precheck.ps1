#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function precheck {
  <#
  .SYNOPSIS
  PreCheck
  .DESCRIPTION
  This function is used as a precheck step by all the functions to test all the required authentication and properties.
  .EXAMPLE
  precheck
  Run the test
  .NOTES
  NAME: precheck
  #>

    $azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile

    if ($azProfile.Contexts.Count -ne 0) {
        if ($null -eq $script:accessToken ) {
            Get-AuthToken
        }
        elseif ($script:accessToken.ExpiresOn.DateTime - [datetime]::UtcNow.AddMinutes(-5) -le 0) {
            # if token expires within 5 minutes, request a new one
            Get-AuthToken
        }

        # Set the subscription from AzContext
        $script:subscriptionId = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile.DefaultContext.Subscription.Id
    }
    else {
        Write-Error 'No subscription available, Please use Connect-AzAccount to login and select the right subscription'
        break
    }
}

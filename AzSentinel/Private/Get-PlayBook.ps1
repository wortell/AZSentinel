#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2
function Get-PlayBook {
    <#
    .SYNOPSIS
    Get PlayBook
    .DESCRIPTION
    This function is used by other function for resolving the Logic Application if Trigger field is defined
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER Name
    Enter the Logic App name

    .PARAMETER FullObject
    If you want to return the full object data
    .EXAMPLE
    Get-LogAnalyticWorkspace -WorkspaceName ""
    This example will get the Workspace and set workspace and baseuri param on Script scope level
    .EXAMPLE
    Get-LogAnalyticWorkspace -WorkspaceName "" -FullObject
    This example will get the Workspace ands return the full data object
    .EXAMPLE
    Get-LogAnalyticWorkspace -SubscriptionId "" -WorkspaceName ""
    This example will get the workspace info from another subscrion than your "Azcontext" subscription
    .NOTES
    NAME: Get-LogicApp
    Get-PlayBook -Name pkmsentinel
    #>
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string] $SubscriptionId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    begin {
        precheck
    }

    process {
        if ($SubscriptionId) {
            Write-Verbose "Getting Worspace from Subscription $($subscriptionId)"
            $uri = "https://management.azure.com/subscriptions/$($subscriptionId)/providers/Microsoft.Logic/workflows?api-version=2016-06-01"
        }
        elseif ($script:subscriptionId) {
            Write-Verbose "Getting Worspace from Subscription $($script:subscriptionId)"
            $uri = "https://management.azure.com/subscriptions/$($script:subscriptionId)/providers/Microsoft.Logic/workflows?api-version=2016-06-01"
        }
        else {
            Write-Error "No SubscriptionID provided" -ErrorAction Stop
        }

        $playBook = (Invoke-RestMethod -Uri $uri -Method get -Headers $script:authHeader).value | Where-Object {$_.name -eq $Name}

        if ($playBook) {
            return $playBook
        }
        else {
            Write-Error "Unable to find workspace $WorkspaceName under Subscription Id: $($script:subscriptionId)" -ErrorAction Stop
        }
    }
}

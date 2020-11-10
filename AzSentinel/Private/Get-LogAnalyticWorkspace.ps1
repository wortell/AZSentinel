#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2
function Get-LogAnalyticWorkspace {
    <#
    .SYNOPSIS
    Get log analytic workspace
    .DESCRIPTION
    This function is used by other function for getting the workspace infiormation and seting the right values for $script:workspace and $script:baseUri
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER WorkspaceName
    Enter the Workspace name
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
    NAME: Get-LogAnalyticWorkspace
    #>
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string] $SubscriptionId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Switch]$FullObject
    )

    begin {
        precheck
    }

    process {
        if ($SubscriptionId) {
            Write-Verbose "Getting Worspace from Subscription $($subscriptionId)"
            $uri = "https://management.azure.com/subscriptions/$($subscriptionId)/providers/Microsoft.OperationalInsights/workspaces?api-version=2015-11-01-preview"
        }
        elseif ($script:subscriptionId) {
            Write-Verbose "Getting Worspace from Subscription $($script:subscriptionId)"
            $uri = "https://management.azure.com/subscriptions/$($script:subscriptionId)/providers/Microsoft.OperationalInsights/workspaces?api-version=2015-11-01-preview"
        }
        else {
            Write-Error "No SubscriptionID provided" -ErrorAction Stop
        }

        try {
            $workspaces = Invoke-webrequest -Uri $uri -Method get -Headers $script:authHeader -ErrorAction Stop
            $workspaceObject = ($workspaces.Content | ConvertFrom-Json).value | Where-Object { $_.name -eq $WorkspaceName }
        }
        catch {
            Write-Error $_.Exception.Message
            break
        }

        if ($workspaceObject) {
            $Script:workspace = ($workspaceObject.id).trim()
            $script:workspaceId = $workspaceObject.properties.customerId
            Write-Verbose "Workspace is: $($Script:workspace)"
            $script:baseUri = "https://management.azure.com$($Script:workspace)"
            if ($FullObject) {
                return $workspaceObject
            }
            Write-Verbose ($workspaceObject | Format-List | Format-Table | Out-String)
            Write-Verbose "Found Workspace $WorkspaceName in RG $($workspaceObject.id.Split('/')[4])"
        }
        else {
            Write-Error "Unable to find workspace $WorkspaceName under Subscription Id: $($script:subscriptionId)"
        }
    }
}

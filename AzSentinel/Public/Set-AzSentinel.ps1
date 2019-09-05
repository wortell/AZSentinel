function Set-AzSentinel {
    <#
    .SYNOPSIS
    Enable Azure Sentinel
    .DESCRIPTION
    This function enables Azure Sentinel trough Rest API Call
    .PARAMETER Subscription
    Enter the subscription ID where the Workspace is deployed
    .PARAMETER ResourceGroup
    Enter the resourceGroup name where the Workspace is deployed
    .PARAMETER Workspace
    Enter the Workspace name
    .PARAMETER Test
    Set $true if you want to run in tests mode without pushing any change
    .EXAMPLE
    Set-AzSentinel -Subscription "" -ResourceGroup "" -Workspace ""
    Run in production mode, changes will be applied
    .EXAMPLE
    Set-AzSentinel -Subscription "" -ResourceGroup "" -Workspace "" -Test $true -Verbose
    Run in Test mode and verbose mode, no changes will be applied
    #>

    [cmdletbinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [string]$Subscription,

        [Parameter(Mandatory)]
        [string]$ResourceGroup,

        [Parameter(Mandatory)]
        [string]$Workspace,

        # Parameter help description
        [Parameter(Mandatory = $false)]
        [bool]
        $Test = $false
    )
    begin {
        if (!$authHeader) {
            $authHeader = Get-AuthToken
        }
        precheck
    }

    process {
        # Variables
        $errorResult = ''

        if ($Test) {
            Write-Output "Running in test mode, no changes will be made"
        }

        $uri = "https://management.azure.com/subscriptions/$subscription/resourceGroups/$resourceGroup/providers/Microsoft.OperationsManagement/solutions/SecurityInsights($workspace)?api-version=2015-11-01-preview"

        Write-Verbose $uri

        $workspaceUrl = "https://management.azure.com/subscriptions/$subscription/resourceGroups/$resourceGroup/providers/Microsoft.OperationalInsights/workspaces/$($workspace)?api-version=2015-11-01-preview"
        try {
            $workspaceResult = ((Invoke-webrequest -Uri $workspaceUrl -Method Get -Headers $authHeader).Content | ConvertFrom-Json)
        }
        catch {
            Write-Verbose $_.Exception.Message
            Write-Error "Unable to find Workspace $Workspace in RG $ResourceGroup and in SUB $Subscription" -ErrorAction Stop
        }
        if ($workspaceResult.properties.provisioningState -eq 'Succeeded') {
            $body = @{
                'id'         = ''
                'etag'       = ''
                'name'       = ''
                'type'       = ''
                'location'   = $workspaceResult.location
                'properties' = @{
                    'workspaceResourceId' = $workspaceResult.id
                }
                'plan'       = @{
                    'name'          = 'SecurityInsights($workspace)'
                    'publisher'     = 'Microsoft'
                    'product'       = 'OMSGallery/SecurityInsights'
                    'promotionCode' = ''
                }
            }

            try {
                $solutionResult = Invoke-webrequest -Uri $uri -Method Get -Headers $authHeader
                Write-Verbose "Sentinel is already enableb on $Workspace and status is: $($solutionResult.StatusDescription)"
            }
            catch {
                $errorReturn = $_
                $errorResult = ($errorReturn | ConvertFrom-Json ).error
                if ($errorResult.Code -eq 'ResourceNotFound') {
                    Write-Verbose "Sentinetal is not enabled on workspace $($Workspace)"
                    if ($Test) {
                        Write-Output ($body | Format-Table | Out-String)
                    }
                    else {
                        try {
                            Write-Verbose "Enabling Sentinel"
                            $result = Invoke-webrequest -Uri $uri -Method Put -Headers $authHeader -Body ($body | ConvertTo-Json)
                            return $result
                        }
                        catch {
                            $errorReturn = $_
                            $errorResult = ($errorReturn | ConvertFrom-Json ).error
                            Write-Error "unable to enable Sentinel on $Workspace with error message: $($errorResult.message)"
                        }
                    }
                }
                else {
                    Write-Verbose $_
                    Write-Error "Unable to invoke webrequest with error message: $($errorResult.message)" -ErrorAction Stop
                }
            }

        }
        else {
            Write-Error "Workspace $Workspace is currently in $workspaceResult.properties.provisioningState status, setup canceled"
        }
    }
}

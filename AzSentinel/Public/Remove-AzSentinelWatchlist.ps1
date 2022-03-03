#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Remove-AzSentinelWatchlist {
    <#
    .SYNOPSIS
    Remove Azure Sentinal Watchlist rule
    .DESCRIPTION
    With this function you can remove Azure Sentinal Watchlist rules
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER WorkspaceName
    Enter the Workspace name
    .PARAMETER Name
    Enter the name of the watchlist rule that you wnat to remove
    .EXAMPLE
    Remove-AzSentinelWatchlist -WorkspaceName "" -Name ""
    In this example the defined watchlist rule will be removed from Azure Sentinel
    .EXAMPLE
    Remove-AzSentinelWatchlist -WorkspaceName "" -Name "","", ""
    In this example you can define multiple watchlist rules that will be removed
    #>

    param (
        [Parameter(Mandatory = $false,
            ParameterSetName = "Sub")]
        [ValidateNotNullOrEmpty()]
        [string] $SubscriptionId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Name
    )

    begin {
        precheck
    }

    process {
        switch ($PsCmdlet.ParameterSetName) {
            Sub {
                $arguments = @{
                    WorkspaceName  = $WorkspaceName
                    SubscriptionId = $SubscriptionId
                }
            }
            default {
                $arguments = @{
                    WorkspaceName = $WorkspaceName
                }
            }
        }

        foreach ($rule in $Name) {
            try {
                $item = Get-AzSentinelWatchlist @arguments -Name $rule -ErrorAction Stop
            }
            catch {
                $return = $_.Exception.Message
                Write-Error $return
            }

            if ($item) {
                $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/watchlists/$($rule)?api-version=2019-01-01-preview"

                try {
                    $result = Invoke-WebRequest -Uri $uri -Method DELETE -Headers $script:authHeader
                    Write-Host "Successfully removed watchlist rule '$rule' with status: $($result.StatusDescription)" -ForegroundColor Green
                }
                catch {
                    Write-Verbose $_
                    Write-Error "Failed to remove watchlist rule '$rule' with error message: '$($_.Exception.Message)'" -ErrorAction Continue
                }
            }
        }
    }
}

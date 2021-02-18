#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Remove-AzSentinelWatchlist {
    <#
    .SYNOPSIS
    Remove Azure Sentinal Watchlist
    .DESCRIPTION
    With this function you can remove Azure Sentinal Alert rules from Powershell, if you don't provide andy Rule name all rules will be removed
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER WorkspaceName
    Enter the Workspace name
    .PARAMETER RuleName
    Enter the name of the rule that you wnat to remove
    .EXAMPLE
    Remove-AzSentinelWatchlist -WorkspaceName "" -DisplayName ""
    In this example the defined rule will be removed from Azure Sentinel
    .EXAMPLE
    Remove-AzSentinelWatchlist -WorkspaceName "" -DisplayName "","", ""
    In this example you can define multiple rules that will be removed
    .EXAMPLE
    Remove-AzSentinelWatchlist -WorkspaceName ""
    In this example no rule is specified, all rules will be removed one by one. For each rule you need to confirm the action
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
        [string[]]$DisplayName
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

        foreach ($rule in $DisplayName) {
            try {
                $item = Get-AzSentinelWatchlist @arguments -DisplayName $rule -ErrorAction Stop
            }
            catch {
                $return = $_.Exception.Message
                Write-Error $return
            }

            if ($item) {
                $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/watchlists/$($rule)?api-version=2019-01-01-preview"

                try {
                    $result = Invoke-WebRequest -Uri $uri -Method DELETE -Headers $script:authHeader
                    Write-Output "Successfully removed rule: $($rule) with status: $($result.StatusDescription)"
                }
                catch {
                    Write-Verbose $_
                    Write-Error "Unable to remove rule: $($rule) with error message: $($_.Exception.Message)" -ErrorAction Continue
                }
            }
            else {
                Write-Warning "$rule not found in $WorkspaceName"
            }
        }
    }
}

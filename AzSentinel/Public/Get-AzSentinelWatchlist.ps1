#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Get-AzSentinelWatchlist {
    <#
    .SYNOPSIS
    Get Azure Sentinel Watchlist
    .DESCRIPTION
    With this function you can get a list of open watchLists from Azure Sentinel.
    You can can also filter to watchList with speciefiek case namber or Case name
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER WorkspaceName
    Enter the Workspace name
    .PARAMETER DisplayName
    Enter watchList name, this is the same name as the alert rule that triggered the watchList
    .PARAMETER All
    Use -All switch to get a list of all the watchLists
    .EXAMPLE
    Get-AzSentinelwatchList -WorkspaceName ""
    Get a list of the last 200 watchLists
    .EXAMPLE
    Get-AzSentinelwatchList -WorkspaceName "" -All
    Get a list of all watchLists
    .EXAMPLE
    Get-AzSentinelwatchList -WorkspaceName "" -Name
    Get information of a specifiek watchList with providing the name
    .EXAMPLE
    Get-AzSentinelwatchList -WorkspaceName "" -Name "", ""
    Get information of one or more watchLists with providing a watchList name, this is the name of the alert rule that triggered the watchList
    #>

    [cmdletbinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $false,
            ParameterSetName = "Sub")]
        [ValidateNotNullOrEmpty()]
        [string] $SubscriptionId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $false)]
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

        try {
            Get-LogAnalyticWorkspace @arguments -ErrorAction Stop
        }
        catch {
            Write-Error $_.Exception.Message
            break
        }

        $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/watchlists?api-version=2019-01-01-preview"
        Write-Verbose -Message "Using URI: $($uri)"

        try {
            $watchListRaw = (Invoke-RestMethod -Uri $uri -Method Get -Headers $script:authHeader)
            $watchList += $watchListRaw.value

            while ($watchListRaw.nextLink) {
                $watchListRaw = (Invoke-RestMethod -Uri $($watchListRaw.nextLink) -Headers $script:authHeader -Method Get)
                $watchList += $watchListRaw.value
            }
        }
        catch {
            Write-Verbose $_
            Write-Error "Unable to get watchlists with error code: $($_.Exception.Message)" -ErrorAction Stop
        }

        $return = @()

        if ($watchList) {
            Write-Verbose "Found $($watchList.count) watchlists"

            if ($Name.Count -ge 1) {
                foreach ($rule in $Name) {

                    [PSCustomObject]$temp = $watchList | Where-Object { $_.name -like $rule }

                    if ($temp) {
                        $temp.properties | Add-Member -NotePropertyName etag -NotePropertyValue $temp.etag -Force
                        $temp.properties | Add-Member -NotePropertyName name -NotePropertyValue $temp.name -Force
                        $return += $temp.properties
                    }
                    else {
                        Write-Error "WatchList ruole '$rule' could not be found"
                    }
                }
                return $return
            }
            else {
                $watchList | ForEach-Object {
                    $_.properties | Add-Member -NotePropertyName etag -NotePropertyValue $_.etag -Force
                    $_.properties | Add-Member -NotePropertyName name -NotePropertyValue $_.name -Force
                }
                return $watchList.properties
            }
        }
        else {
            Write-Verbose "No watchList found on $($WorkspaceName)"
        }
    }
}

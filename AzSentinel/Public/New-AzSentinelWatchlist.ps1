#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function New-AzSentinelWatchlist {
    <#
    .SYNOPSIS
    Create Azure Sentinal Watchlist
    .DESCRIPTION
    Use this function to creates Azure Sentinal Hunting rule
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER WorkspaceName
    Enter the Workspace name
    .PARAMETER Name
    Enter the Display name for the hunting rule
    .EXAMPLE
    New-AzSentinelHuntingRule -WorkspaceName "" -Name "" -Description "" -Tactics "","" -Query ''
    In this example you create a new hunting rule by defining the rule properties from CMDLET
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $false,
            ParameterSetName = "Sub")]
        [ValidateNotNullOrEmpty()]
        [string] $SubscriptionId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $WorkspaceName,

        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [string] $Description,

        [Parameter(Mandatory = $false)]
        [System.IO.FileInfo] $WatchListFile,

        [Parameter(Mandatory = $false)]
        [psobject] $WatchListObject
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

        if ($WatchListFile) {
            if ($WatchListFile.Extension -eq '.csv') {
                try {
                    $watchlistInput = (Get-Content $WatchListFile -Raw)
                }
                catch {
                    Write-Error $_.Exception.Message
                }
            } elseif ($WatchListFile.Extension -eq '.json') {
                try {
                    $watchlistInput = (Get-Content $WatchListFile | ConvertTo-Csv)
                }
                catch {
                    Write-Error $_.Exception.Message
                    return
                }
            }
            else {
                Write-Error "Not supported file extensions"
            }
        }
        elseif ($null -ne $WatchListObject) {
            $watchlistInput = $WatchListObject
        }
        else {
            #empty example
            $watchlistInput = "This line will be skipped\nheader1,header2\nvalue1,value2"
        }

        Write-Verbose -Message "Creating new Watchlists: $($Name)"

        try {
            Write-Verbose -Message "Get Watchlists rule $Name"
            $item = Get-AzSentinelWatchlist @arguments -Name $Name -ErrorAction SilentlyContinue

            if ($item) {
                Write-Verbose -Message "Watchlists rule $($Name) exists in Azure Sentinel"
                $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/watchlists/$($Name)?api-version=2019-01-01-preview"
            }
            else {
                $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/watchlists/$($Name)?api-version=2019-01-01-preview"
            }
        }
        catch {
            Write-Verbose $_
            Write-Error "Unable to connect to APi to get Analytic rules with message: $($_.Exception.Message)" -ErrorAction Stop
        }

        <#
            Build Class
        #>
        try {
            $body = [Watchlist]::new(
                $Name,
                $watchlistInput,
                $Description,
                0
            )

             return $body.properties
# $body = @"
# {
#     "properties": {
#         "contentType": "text/csv",
#         "description": "csv1",
#         "Name": "$Name",
#         "numberOfLinesToSkip": "0",
#         "provider": "Microsoft",
#         "rawContent": "$watchlistInput",
#         "source": "Local file"
#     }
# }
# "@
        }
        catch {
            Write-Error "Unable to initiate class with error: $($_.Exception.Message)" -ErrorAction Continue
        }
        <#
            Try to create or update Hunting Rule
        #>
        try {
            $result = Invoke-RestMethod -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json)
            #$body.Properties | Add-Member -NotePropertyName status -NotePropertyValue $($result.StatusDescription) -Force
            return $result.properties

            Write-Verbose "Successfully updated watchlist rule: $($item.Name) with status: $($result.uploadStatus)"
        }
        catch {
            Write-Verbose $_
            Write-Error "Unable to invoke webrequest for rule $($item.Name) with error message: $($_.Exception.Message)" -ErrorAction Continue

        }
    }
}

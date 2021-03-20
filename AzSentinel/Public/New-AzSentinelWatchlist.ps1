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
    .PARAMETER DisplayName
    Enter the Display name for the hunting rule
    .EXAMPLE
    New-AzSentinelHuntingRule -WorkspaceName "" -DisplayName "" -Description "" -Tactics "","" -Query ''
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
        [string] $DisplayName

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

        $item = @{ }

        Write-Verbose -Message "Creating new Watchlists: $($DisplayName)"

        try {
            Write-Verbose -Message "Get Watchlists rule $DisplayName"
            $content = Get-AzSentinelWatchlist @arguments -DisplayName $DisplayName

            if ($content) {
                Write-Verbose -Message "Watchlists rule $($DisplayName) exists in Azure Sentinel"
                $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/watchlists/$($DisplayName)?api-version=2019-01-01-preview"
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
            # $bodyProp = [Hunting]::new(
            #     $DisplayName,
            #     $Query,
            #     $Description,
            #     $Tactics
            # )

            # $body = [HuntingRule]::new( $item.name, $item.etag, $item.Id, $bodyProp)

$body = @"
{
    "properties": {
        "contentType": "text/csv",
        "description": "csv1",
        "displayName": "$DisplayName",
        "numberOfLinesToSkip": "0",
        "provider": "Microsoft",
        "rawContent": "This line will be skipped\nheader1,header2\nvalue1,value2",
        "source": "Local file"
    }
}
"@
        }
        catch {
            Write-Error "Unable to initiate class with error: $($_.Exception.Message)" -ErrorAction Continue
        }
        <#
            Try to create or update Hunting Rule
        #>
        try {
            $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body $body
            #$body.Properties | Add-Member -NotePropertyName status -NotePropertyValue $($result.StatusDescription) -Force
            return $body.Properties

            Write-Verbose "Successfully updated hunting rule: $($item.displayName) with status: $($result.StatusDescription)"
        }
        catch {
            Write-Verbose $_
            Write-Error "Unable to invoke webrequest for rule $($item.displayName) with error message: $($_.Exception.Message)" -ErrorAction Continue

        }
    }
}

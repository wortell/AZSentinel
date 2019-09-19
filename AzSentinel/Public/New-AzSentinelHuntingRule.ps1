#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -module @{ModuleNAme = 'powershell-yaml'; ModuleVersion = '0.4.0'}
#requires -version 6.2

function New-AzSentinelHuntingRule {
    <#
    .SYNOPSIS
    Create Azure Sentinal Hunting Rule
    .DESCRIPTION
    Use this function to creates Azure Sentinal Hunting rule
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER WorkspaceName
    Enter the Workspace name
    .PARAMETER DisplayName
    Enter the Display name for the hunting rule
    .PARAMETER Description
    Enter the Description for the hunting rule
    .PARAMETER Tactics
    Enter the Tactics, valid values: "InitialAccess", "Persistence", "Execution", "PrivilegeEscalation", "DefenseEvasion", "CredentialAccess", "LateralMovement", "Discovery", "Collection", "Exfiltration", "CommandAndControl", "Impact"
    .PARAMETER Query
    Enter the querry in KQL format
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
        [string] $DisplayName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Query,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Description,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Tactics[]] $Tactics

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
        Get-LogAnalyticWorkspace @arguments

        $item = @{ }
        $content = $null
        $body = @{ }
        $compareResult1 = $null
        $compareResult2 = $null
        $compareResult = $null

        Write-Verbose -Message "Creating new Hunting rule: $($DisplayName)"

        try {
            Write-Verbose -Message "Get hunting rule $DisplayName"
            $content = Get-AzSentinelHuntingRule @arguments -RuleName $DisplayName -WarningAction SilentlyContinue

            if ($content) {
                Write-Verbose -Message "Hunting rule $($DisplayName) exists in Azure Sentinel"

                $item | Add-Member -NotePropertyName name -NotePropertyValue $content.name -Force
                $item | Add-Member -NotePropertyName etag -NotePropertyValue $content.eTag -Force
                $item | Add-Member -NotePropertyName Id -NotePropertyValue $content.id -Force


                $uri = "$script:baseUri/savedSearches/$($content.name)?api-version=2017-04-26-preview"
            }
            else {
                Write-Verbose -Message "Hunting rule $($DisplayName) doesn't exists in Azure Sentinel"

                $guid = (New-Guid).Guid

                $item | Add-Member -NotePropertyName name -NotePropertyValue $guid -Force
                $item | Add-Member -NotePropertyName etag -NotePropertyValue $null -Force
                $item | Add-Member -NotePropertyName Id -NotePropertyValue "$script:Workspace/savedSearches/$guid" -Force

                $uri = "$script:baseUri/savedSearches/$($guid)?api-version=2017-04-26-preview"
            }
        }
        catch {
            $errorReturn = $_
            $errorResult = ($errorReturn | ConvertFrom-Json ).error
            Write-Verbose $_
            Write-Error "Unable to connect to APi to get Analytic rules with message: $($errorResult.message)" -ErrorAction Stop
        }

        [PSCustomObject]$body = @{
            "name"       = $item.name
            "eTag"       = $item.etag
            "id"         = $item.id
            "properties" = @{
                'Category'             = 'Hunting Queries'
                'DisplayName'          = $DisplayName
                'Query'                = $Query
                [pscustomobject]'Tags' = @(
                    @{
                        'Name'  = "description"
                        'Value' = $Description
                    },
                    @{
                        "Name"  = "tactics"
                        "Value" = $Tactics -join ','
                    },
                    @{
                        "Name"  = "createdBy"
                        "Value" = ""
                    },
                    @{
                        "Name"  = "createdTimeUtc"
                        "Value" = ""
                    }
                )
            }
        }

        #return $body | ConvertTo-Json -Depth 10

        #return $content
        if ($content) {
            $compareResult1 = Compare-Policy -ReferenceTemplate ($content | Select-Object * -ExcludeProperty lastModifiedUtc, alertRuleTemplateName, name, etag, id, Tags, Version) -DifferenceTemplate ($body.Properties | Select-Object * -ExcludeProperty name, Tags, Version)
            $compareResult2 = Compare-Policy -ReferenceTemplate ($content.Tags | Where-Object { $_.name -eq "tactics" }) -DifferenceTemplate ($body.Properties.Tags | Where-Object { $_.name -eq "tactics" })
            $compareResult = [PSCustomObject]$compareResult1 + [PSCustomObject]$compareResult2

            if ($compareResult) {
                Write-Output "Found Differences for hunting rule: $($DisplayName)"
                Write-Output ($compareResult | Format-Table | Out-String)

                if ($PSCmdlet.ShouldProcess("Do you want to update hunting rule: $($DisplayName)")) {
                    try {
                        Write-Output ($body.properties | Format-Table)

                        $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json -Depth 10)
                        Write-Output "Successfully updated hunting rule: $($DisplayName) with status: $($result.StatusDescription)"
                    }
                    catch {
                        $errorReturn = $_
                        $errorResult = ($errorReturn | ConvertFrom-Json).error
                        Write-Verbose $_.Exception.Message
                        Write-Error "Unable to invoke webrequest with error message: $($errorResult.message)" -ErrorAction Stop
                    }
                }
                else {
                    Write-Output "No change have been made for rule $($DisplayName), deployment aborted"
                }
            }
            else {
                Write-Output "Hunting rule $($DisplayName) is compliance, nothing to do"
                Write-Output ($body.properties | Format-Table)
            }
        }
        else {
            Write-Verbose "Creating new hunting rule: $($DisplayName)"

            try {

                $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json -Depth 10)
                Write-Output "Successfully created hunting rule: $($DisplayName) with status: $($result.StatusDescription)"
                Write-Output ($body.properties | Format-Table)
            }
            catch {
                $errorReturn = $_
                $errorResult = ($errorReturn | ConvertFrom-Json ).error
                Write-Verbose $_.Exception.Message
                Write-Error "Unable to invoke webrequest with error message: $($errorResult.message)" -ErrorAction Stop
            }
        }
    }
}

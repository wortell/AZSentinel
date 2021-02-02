#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
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

        $item = @{ }

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
            Write-Verbose $_
            Write-Error "Unable to connect to APi to get Analytic rules with message: $($_.Exception.Message)" -ErrorAction Stop
        }

        <#
            Build Class
        #>
        try {
            $bodyProp = [Hunting]::new(
                $DisplayName,
                $Query,
                $Description,
                $Tactics
            )

            $body = [HuntingRule]::new( $item.name, $item.etag, $item.Id, $bodyProp)
        }
        catch {
            Write-Error "Unable to initiate class with error: $($_.Exception.Message)" -ErrorAction Continue
        }

        <#
            Try to create or update Hunting Rule
            #>
        try {
            $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json -Depth 10 -EnumsAsStrings)
            $body.Properties | Add-Member -NotePropertyName status -NotePropertyValue $($result.StatusDescription) -Force
            return $body.Properties

            Write-Verbose "Successfully updated hunting rule: $($item.displayName) with status: $($result.StatusDescription)"
        }
        catch {
            Write-Verbose $_
            Write-Error "Unable to invoke webrequest for rule $($item.displayName) with error message: $($_.Exception.Message)" -ErrorAction Continue

        }
    }
}

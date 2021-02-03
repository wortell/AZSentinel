#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Import-AzSentinelHuntingRule {
    <#
    .SYNOPSIS
    Import Azure Sentinal Hunting rule
    .DESCRIPTION
    This function imports Azure Sentinal Hunnting rules from JSON and YAML config files.
    This way you can manage your Hunting rules dynamic from JSON or multiple YAML files
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER WorkspaceName
    Enter the Workspace name
    .PARAMETER SettingsFile
    Path to the JSON or YAML file for the Hunting rules
    .EXAMPLE
    Import-AzSentinelHuntingRule -WorkspaceName "infr-weu-oms-t-7qodryzoj6agu" -SettingsFile ".\examples\HuntingRules.json"
    In this example all the rules configured in the JSON file will be created or updated
    .EXAMPLE
    Import-AzSentinelHuntingRule -WorkspaceName "" -SettingsFile ".\examples\HuntingRules.yaml"
    In this example all the rules configured in the YAML file will be created or updated
    .EXAMPLE
    Get-Item .\examples\HuntingRules*.json | Import-AzSentinelHuntingRule -WorkspaceName ""
    In this example you can select multiple JSON files and Pipeline it to the SettingsFile parameter
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

        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript( { (Test-Path -Path $_) -and ($_.Extension -in '.json', '.yaml', '.yml') })]
        [System.IO.FileInfo] $SettingsFile
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

        if ($SettingsFile.Extension -eq '.json') {
            try {
                $content = (Get-Content $SettingsFile -Raw | ConvertFrom-Json -ErrorAction Stop)
                if ($content.analytics) {
                    $hunting = $content.analytics
                }
                else {
                    $hunting = $content.Hunting
                }

                Write-Verbose -Message "Found $($hunting.count) rules"
            }
            catch {
                Write-Verbose $_
                Write-Error -Message 'Unable to convert JSON file' -ErrorAction Stop
            }
        }
        elseif ($SettingsFile.Extension -in '.yaml', 'yml') {
            try {
                $hunting = [pscustomobject](Get-Content $SettingsFile -Raw | ConvertFrom-Yaml -ErrorAction Stop)
                $hunting | Add-Member -MemberType NoteProperty -Name DisplayName -Value $hunting.name
                Write-Verbose -Message 'Found compatibel yaml file'
            }
            catch {
                Write-Verbose $_
                Write-Error -Message 'Unable to convert yaml file' -ErrorAction Stop
            }
        }

        try {
            $allRulesContent = Get-AzSentinelHuntingRule @arguments -RuleName $($hunting.displayName) -WarningAction SilentlyContinue -ErrorAction Stop
        }
        catch {
            Write-Error $_.Exception.Message
            break
        }

        $return = @()

        foreach ($item in $hunting) {
            Write-Verbose "Started with Hunting rule: $($item.displayName)"

            try {
                Write-Verbose -Message "Get rule $($item.description)"

                $content = $allRulesContent | Where-Object displayName -eq $item.displayName

                if ($content) {
                    Write-Verbose -Message "Hunting rule $($item.displayName) exists in Azure Sentinel"

                    $item | Add-Member -NotePropertyName name -NotePropertyValue $content.name -Force
                    $item | Add-Member -NotePropertyName etag -NotePropertyValue $content.etag -Force
                    $item | Add-Member -NotePropertyName Id -NotePropertyValue $content.id -Force

                    $uri = "$script:baseUri/savedSearches/$($content.name)?api-version=2017-04-26-preview"
                }
                else {
                    Write-Verbose -Message "Hunting rule $($item.displayName) doesn't exists in Azure Sentinel"

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
                    $item.displayName,
                    $item.query,
                    $item.description,
                    $item.tactics
                )

                $body = [HuntingRule]::new( $item.name, $item.eTag, $item.Id, $bodyProp)
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
                $return += $body.Properties

                Write-Verbose "Successfully updated hunting rule: $($item.displayName) with status: $($result.StatusDescription)"
            }
            catch {
                Write-Verbose $_
                Write-Error "Unable to invoke webrequest for rule $($item.displayName) with error message: $($_.Exception.Message)" -ErrorAction Continue

            }
        }
        return $return
    }
}

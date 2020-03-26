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
        Get-LogAnalyticWorkspace @arguments

        $item = @{ }

        if ($SettingsFile.Extension -eq '.json') {
            try {
                $analytics = (Get-Content $SettingsFile -Raw | ConvertFrom-Json -ErrorAction Stop).analytics
                Write-Verbose -Message "Found $($analytics.count) rules"
            }
            catch {
                Write-Verbose $_
                Write-Error -Message 'Unable to convert JSON file' -ErrorAction Stop
            }
        }
        elseif ($SettingsFile.Extension -in '.yaml', 'yml') {
            try {
                $analytics = [pscustomobject](Get-Content $SettingsFile -Raw | ConvertFrom-Yaml -ErrorAction Stop)
                $analytics | Add-Member -MemberType NoteProperty -Name DisplayName -Value $analytics.name
                Write-Verbose -Message 'Found compatibel yaml file'
            }
            catch {
                Write-Verbose $_
                Write-Error -Message 'Unable to convert yaml file' -ErrorAction Stop
            }
        }

        foreach ($item in $analytics) {
            Write-Output "Started with Hunting rule: $($item.displayName)"

            try {
                Write-Verbose -Message "Get rule $($item.description)"
                $content = Get-AzSentinelHuntingRule @arguments -RuleName $($item.displayName) -WarningAction SilentlyContinue

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

            [PSCustomObject]$body = @{
                "name"       = $item.name
                "eTag"       = $item.etag
                "id"         = $item.id
                "properties" = @{
                    'Category'             = 'Hunting Queries'
                    'DisplayName'          = [string]$item.displayName
                    'Query'                = [string]$item.query
                    [pscustomobject]'Tags' = @(
                        @{
                            'Name'  = "description"
                            'Value' = [string]$item.description
                        },
                        @{
                            "Name"  = "tactics"
                            "Value" = [Tactics[]] $item.tactics -join ','
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

            if ($content) {
                $compareResult1 = Compare-Policy -ReferenceTemplate ($content | Select-Object * -ExcludeProperty lastModifiedUtc, alertRuleTemplateName, name, etag, id, Tags, Version) -DifferenceTemplate ($body.Properties | Select-Object * -ExcludeProperty name, Tags, Version)
                $compareResult2 = Compare-Policy -ReferenceTemplate ($content.Tags | Where-Object { $_.name -eq "tactics" }) -DifferenceTemplate ($body.Properties.Tags | Where-Object { $_.name -eq "tactics" })
                $compareResult = [PSCustomObject]$compareResult1 + [PSCustomObject]$compareResult2

                if ($compareResult) {
                    Write-Output "Found Differences for hunting rule: $($item.displayName)"
                    Write-Output ($compareResult | Format-Table | Out-String)

                    if ($PSCmdlet.ShouldProcess("Do you want to update hunting rule: $($body.Properties.DisplayName)")) {
                        try {
                            $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json -Depth 10 -EnumsAsStrings)
                            Write-Output "Successfully updated hunting rule: $($item.displayName) with status: $($result.StatusDescription)"
                            Write-Output ($body.Properties | Format-List | Format-Table | Out-String)
                        }
                        catch {
                            Write-Verbose $_
                            Write-Error "Unable to invoke webrequest with error message: $($_.Exception.Message)" -ErrorAction Continue
                        }
                    }
                    else {
                        Write-Output "No change have been made for hunting rule $($item.displayName), deployment aborted"
                    }
                }
                else {
                    Write-Output "Hunting rule $($item.displayName) is compliance, nothing to do"
                    Write-Output ($body.Properties | Format-List | Format-Table | Out-String)
                }
            }
            else {
                Write-Verbose "Creating new rule: $($item.displayName)"

                try {
                    $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json -Depth 10 -EnumsAsStrings)
                    Write-Output "Successfully created hunting rule: $($item.displayName) with status: $($result.StatusDescription)"
                    Write-Output ($body.Properties | Format-List | Format-Table | Out-String)
                }
                catch {
                    Write-Verbose $_
                    Write-Error "Unable to invoke webrequest with error message: $($_.Exception.Message)" -ErrorAction Continue
                }
            }
        }
    }
}

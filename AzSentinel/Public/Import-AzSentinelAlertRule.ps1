#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -module @{ModuleNAme = 'powershell-yaml'; ModuleVersion = '0.4.0'}
#requires -version 6.2

function Import-AzSentinelAlertRule {
    <#
    .SYNOPSIS
    Import Azure Sentinal Alert rule
    .DESCRIPTION
    This function imports Azure Sentinal Alert rules from JSON and YAML config files.
    This way you can manage your Alert rules dynamic from JSON or multiple YAML files
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER WorkspaceName
    Enter the Workspace name
    .PARAMETER SettingsFile
    Path to the JSON or YAML file for the AlertRules
    .EXAMPLE
    Import-AzSentinelAlertRule -WorkspaceName "" -SettingsFile ".\examples\AlertRules.json"
    In this example all the rules configured in the JSON file will be created or updated
    .EXAMPLE
    Import-AzSentinelAlertRule -WorkspaceName "" -SettingsFile ".\examples\SuspectApplicationConsent.yaml"
    In this example all the rules configured in the YAML file will be created or updated
    .EXAMPLE
    Get-Item .\examples\*.json | Import-AzSentinelAlertRule -WorkspaceName ""
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

        $errorResult = ''

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
            Write-Verbose -Message "Started with rule: $($item.displayName)"

            $guid = (New-Guid).Guid

            try {
                Write-Verbose -Message "Get rule $($item.description)"
                $content = Get-AzSentinelAlertRule @arguments -RuleName $($item.displayName) -ErrorAction SilentlyContinue

                if ($content) {
                    Write-Verbose -Message "Rule $($item.displayName) exists in Azure Sentinel"

                    $item | Add-Member -NotePropertyName name -NotePropertyValue $content.name -Force
                    $item | Add-Member -NotePropertyName etag -NotePropertyValue $content.etag -Force
                    $item | Add-Member -NotePropertyName Id -NotePropertyValue $content.id -Force

                    $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/alertRules/$($content.name)?api-version=2019-01-01-preview"
                }
                else {
                    Write-Verbose -Message "Rule $($item.displayName) doesn't exists in Azure Sentinel"

                    $item | Add-Member -NotePropertyName name -NotePropertyValue $guid -Force
                    $item | Add-Member -NotePropertyName etag -NotePropertyValue $null -Force
                    $item | Add-Member -NotePropertyName Id -NotePropertyValue "$script:Workspace/providers/Microsoft.SecurityInsights/alertRules/$guid" -Force
                    $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/alertRules/$($guid)?api-version=2019-01-01-preview"
                }
            }
            catch {
                $errorReturn = $_
                $errorResult = ($errorReturn | ConvertFrom-Json ).error
                Write-Verbose $_
                Write-Error "Unable to connect to APi to get Analytic rules with message: $($errorResult.message)" -ErrorAction Stop
            }

            try {
                $bodyAlertProp = [AlertProp]::new(
                    $item.name,
                    $item.displayName,
                    $item.description,
                    $item.severity,
                    $item.enabled,
                    $item.query,
                    $item.queryFrequency,
                    $item.queryPeriod,
                    $item.triggerOperator,
                    $item.triggerThreshold,
                    $item.suppressionDuration,
                    $item.suppressionEnabled,
                    $item.tactics
                )
                $body = [AlertRule]::new( $item.name, $item.etag, $bodyAlertProp, $item.Id)
            }
            catch {
                Write-Error "Unable to initiate class with error: $($_.Exception.Message)" -ErrorAction Stop
            }

            if ($content) {
                $compareResult = Compare-Policy -ReferenceTemplate ($content | Select-Object * -ExcludeProperty lastModifiedUtc, alertRuleTemplateName, name, etag, id) -DifferenceTemplate ($body.Properties | Select-Object * -ExcludeProperty name)
                if ($compareResult) {
                    Write-Output "Found Differences for rule: $($item.displayName)"
                    Write-Output ($compareResult | Format-Table | Out-String)

                    if ($PSCmdlet.ShouldProcess("Do you want to update profile: $($body.Properties.DisplayName)")) {
                        try {
                            $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json)
                            Write-Output "Successfully updated rule: $($item.displayName) with status: $($result.StatusDescription)"
                            Write-Output ($body.Properties | Format-List | Format-Table | Out-String)
                        }
                        catch {
                            $errorReturn = $_
                            $errorResult = ($errorReturn | ConvertFrom-Json ).error
                            Write-Verbose $_.Exception.Message
                            Write-Error "Unable to invoke webrequest with error message: $($errorResult.message)" -ErrorAction Stop
                        }
                    }
                    else {
                        Write-Output "No change have been made for rule $($item.displayName), deployment aborted"
                    }
                }
                else {
                    Write-Output "Rule $($item.displayName) is compliance, nothing to do"
                    Write-Output ($body.Properties | Format-List | Format-Table | Out-String)
                }
            }
            else {
                Write-Verbose "Creating new rule: $($item.displayName)"

                try {
                    $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json)
                    Write-Output "Successfully created rule: $($item.displayName) with status: $($result.StatusDescription)"
                    Write-Output ($body.Properties | Format-List | Format-Table | Out-String)
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
}

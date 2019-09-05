#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -module @{ModuleNAme = 'powershell-yaml'; ModuleVersion = '0.4.0'}
#requires -version 6.0

using module Az.Accounts

function New-AzAnalytic {
    <#
    .SYNOPSIS
    Manage Azure Sentinal Alert Rules
    .DESCRIPTION
    This function creates Azure Sentinal Alert rules from JSON and YAML config files.
    This way you can manage your Alert rules dynamic from one JSON or multiple YAML files
    .PARAMETER subscription
    Enter the subscription ID where the Workspace is deployed
    .PARAMETER resourceGroup
    Enter the resourceGroup name where the Workspace is deployed
    .PARAMETER workspace
    Enter the Workspace name
    .PARAMETER SettingsFile
    Path to the JSON or YAML file for the AlertRules
    .EXAMPLE
    New-AzAnalytic -Subscription "" -ResourceGroup "" -Workspace "" -SettingsFile ".\examples\AlertRules.json" -Verbose
    Deploy example, this module support Json and Yaml format
    #>

    [cmdletbinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [string]$Subscription,

        # Parameter help description
        [Parameter(Mandatory)]
        [string]$ResourceGroup,

        # Parameter help description
        [Parameter(Mandatory)]
        [string]$Workspace,

        # Parameter help description
        [Parameter(Mandatory)]
        [string]$SettingsFile
    )

    begin {
        if (!$authHeader) {
            $authHeader = Get-AuthToken
        }
        precheck
    }

    process {
        # Variables
        $errorResult = ''

        $getUri = "https://management.azure.com/subscriptions/$Subscription/resourceGroups/$ResourceGroup/providers/Microsoft.OperationalInsights/workspaces/$Workspace/providers/Microsoft.SecurityInsights/alertRules?api-version=2019-01-01-preview"

        # If JSON Format
        if (($SettingsFile.Split('.')[-1]) -eq 'json') {
            try {
                if (Test-Path $SettingsFile) {
                    $analytics = (Get-Content $SettingsFile -Raw | ConvertFrom-Json).analytics
                    Write-Verbose "Found $($analytics.count) rules"
                }
                else {
                    Write-Error "JSON file not found" -ErrorAction Stop
                }
            }
            catch {
                Write-Verbose $_
                Write-Error "Unable to convert JSON file"
            }

            foreach ($item in $analytics) {
                Write-Verbose "Started with rule: $($item.displayName)"

                $guid = (New-Guid).Guid

                try {
                    Write-Verbose "Getting all current Analytic rules"
                    $contents = Invoke-webrequest -Uri $getUri -Method get -Headers $authHeader
                    $content = ($contents.Content | ConvertFrom-Json).value | Where-Object { $_.properties.displayName -eq $item.displayName }

                    if ($content) {
                        Write-Verbose "Rule $($item.displayName) exists in Azure Sentinel"

                        $item | Add-Member -NotePropertyName name -NotePropertyValue $content.name -Force
                        $item | Add-Member -NotePropertyName etag -NotePropertyValue $content.etag -Force
                        $item | Add-Member -NotePropertyName Id -NotePropertyValue $content.id -Force

                        $uri = "https://management.azure.com/subscriptions/$Subscription/resourceGroups/$ResourceGroup/providers/Microsoft.OperationalInsights/workspaces/$Workspace/providers/Microsoft.SecurityInsights/alertRules/$($content.name)?api-version=2019-01-01-preview"
                    }
                    else {
                        Write-Verbose "Rule $($item.displayName) doesn't exists in Azure Sentinel"

                        $item | Add-Member -NotePropertyName name -NotePropertyValue $guid -Force
                        $item | Add-Member -NotePropertyName etag -NotePropertyValue $null -Force
                        $item | Add-Member -NotePropertyName Id -NotePropertyValue "/subscriptions/$Subscription/resourceGroups/$ResourceGroup/providers/Microsoft.OperationalInsights/workspaces/$Workspace/providers/Microsoft.SecurityInsights/alertRules/$guid" -Force

                        $uri = "https://management.azure.com/subscriptions/$Subscription/resourceGroups/$ResourceGroup/providers/Microsoft.OperationalInsights/workspaces/$Workspace/providers/Microsoft.SecurityInsights/alertRules/$($guid)?api-version=2019-01-01-preview"
                    }
                }
                catch {
                    $errorReturn = $_
                    $errorResult = ($errorReturn | ConvertFrom-Json ).error
                    Write-Verbose $_
                    Write-Error "Unable to connect to APi to get Analytic rules with message: $($errorResult.message)" -ErrorAction Stop
                }

                try {
                    $bodyAlertProp = [alertProp]::new(
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

                Write-Output ($body.Properties | Format-List | Format-Table | Out-String)

                if ($content) {
                    $compareResult = Compare-Policy -ReferenceTemplate ($content.properties | Select-Object * -ExcludeProperty lastModifiedUtc, alertRuleTemplateName) -DifferenceTemplate ($body.Properties | Select-Object * -ExcludeProperty Name)
                    if ($compareResult) {
                        Write-Verbose "Found Differences for rule: $($item.displayName)"
                        Write-Output ($compareResult | Format-Table | Out-String)

                        if ($PSCmdlet.ShouldProcess("Do you want to update profile: $($body.Properties.DisplayName)")) {
                            try {
                                $result = Invoke-webrequest -Uri $uri -Method Put -Headers $authHeader -Body ($body | ConvertTo-Json)
                                Write-Output $result.StatusDescription
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
                }
                else {
                    Write-Verbose "Creating new rule: $($item.displayName)"

                    try {
                        $result = Invoke-webrequest -Uri $uri -Method Put -Headers $authHeader -Body ($body | ConvertTo-Json)
                        Write-Output $result.StatusDescription
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
        # End of JSON

        # If YAML format
        elseif (($SettingsFile.Split('.')[-1]) -eq 'yaml' -or ($SettingsFile.Split('.')[-1]) -eq 'yml') {
            try {
                if (Test-Path $SettingsFile) {
                    $item = (Get-Content $SettingsFile -Raw | ConvertFrom-Yaml)
                    Write-Verbose "Found compatibel file"
                }
                else {
                    Write-Error "YAML file not found" -ErrorAction Stop
                }
            }
            catch {
                Write-Verbose $_.Exception.Message
                Write-Error "Unable to convert YAML file" -ErrorAction Stop
            }

            Write-Verbose "Started with rule: $($item.name)"

            $guid = (New-Guid).Guid

            try {
                Write-Verbose "Getting all current Analytic rules"
                $contents = Invoke-webrequest -Uri $getUri -Method get -Headers $authHeader
                $content = ($contents.Content | ConvertFrom-Json).value | Where-Object { $_.properties.displayName -eq $item.name }

                if ($content) {
                    Write-Verbose "Rule $($item.name) exists in Azure Sentinel"

                    $item | Add-Member -NotePropertyName guid -NotePropertyValue $content.name -Force
                    $item | Add-Member -NotePropertyName etag -NotePropertyValue $content.etag -Force
                    $item | Add-Member -NotePropertyName Id -NotePropertyValue $content.id -Force

                    $uri = "https://management.azure.com/subscriptions/$Subscription/resourceGroups/$ResourceGroup/providers/Microsoft.OperationalInsights/workspaces/$Workspace/providers/Microsoft.SecurityInsights/alertRules/$($content.name)?api-version=2019-01-01-preview"
                }
                else {
                    Write-Verbose "Rule $($item.name) doesn't exists in Azure Sentinel"

                    $item | Add-Member -NotePropertyName guid -NotePropertyValue $guid -Force
                    $item | Add-Member -NotePropertyName etag -NotePropertyValue $null -Force
                    $item | Add-Member -NotePropertyName Id -NotePropertyValue "/subscriptions/$Subscription/resourceGroups/$ResourceGroup/providers/Microsoft.OperationalInsights/workspaces/$Workspace/providers/Microsoft.SecurityInsights/alertRules/$guid" -Force

                    $uri = "https://management.azure.com/subscriptions/$Subscription/resourceGroups/$ResourceGroup/providers/Microsoft.OperationalInsights/workspaces/$Workspace/providers/Microsoft.SecurityInsights/alertRules/$($guid)?api-version=2019-01-01-preview"
                }
            }
            catch {
                $errorReturn = $_
                $errorResult = ($errorReturn | ConvertFrom-Json ).error
                Write-Verbose $_
                Write-Error "Unable to connect to APi to get Analytic rules with message: $($errorResult.message)" -ErrorAction Stop
            }

            $bodyAlertProp = [alertProp]::new(
                $item.guid,
                $item.name,
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
            $body = [AlertRule]::new( $item.guid, $item.etag, $bodyAlertProp, $item.Id )

            Write-Output ($body.Properties | Format-List | Format-Table | Out-String)

            if ($content) {
                $compareResult = Compare-Policy -ReferenceTemplate ($content.properties | Select-Object * -ExcludeProperty lastModifiedUtc, alertRuleTemplateName) -DifferenceTemplate ($body.Properties | Select-Object * -ExcludeProperty Name)
                if ($compareResult) {
                    Write-Verbose "Found Differences for rule: $($item.displayName)"
                    Write-Output ($compareResult | Format-Table | Out-String)

                    if ($PSCmdlet.ShouldProcess("Do you want to update profile: $($body.Properties.DisplayName)")) {
                        try {
                            $result = Invoke-webrequest -Uri $uri -Method Put -Headers $authHeader -Body ($body | ConvertTo-Json)
                            Write-Output $result.StatusDescription
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
            }
            else {
                Write-Verbose "Creating new rule: $($item.displayName)"

                try {
                    $result = Invoke-webrequest -Uri $uri -Method Put -Headers $authHeader -Body ($body | ConvertTo-Json)
                    Write-Output $result.StatusDescription
                }
                catch {
                    $errorReturn = $_
                    $errorResult = ($errorReturn | ConvertFrom-Json ).error
                    Write-Verbose $_.Exception.Message
                    Write-Error "Unable to invoke webrequest with error message: $($errorResult.message)" -ErrorAction Stop
                }
            }

        }
        # End of YAML

        # If no match found
        else {
            Write-Error "File extension $($SettingsFile.Split('.')[-1]) is not supported" -ErrorAction Stop
        }
        # End

    }
}

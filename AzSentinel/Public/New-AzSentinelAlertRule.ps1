#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -module @{ModuleNAme = 'powershell-yaml'; ModuleVersion = '0.4.0'}
#requires -version 6.2

function New-AzSentinelAlertRule {
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
    New-AzSentinelAlertRule -Subscription "" -ResourceGroup "" -Workspace "" -SettingsFile ".\examples\AlertRules.json" -verbose
    in this example all the rules configured in the JSON file will be created or updated
    .EXAMPLE
    Get-Item .\examples\*.json | New-AzSentinelAlertRule -Subscription "" -ResourceGroup "" -Workspace ""
    In this example you can select multiple JSON files and Pipeline it to the module
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Subscription,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ResourceGroup,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Workspace,

        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript( { (Test-Path -Path $_) -and ($_.Extension -in '.json', '.yaml', '.yml') })]
        [System.IO.FileInfo] $SettingsFile
    )

    begin {
        precheck
    }
    process {
        $errorResult = ''

        $getUri = "https://management.azure.com/subscriptions/$Subscription/resourceGroups/$ResourceGroup/providers/Microsoft.OperationalInsights/workspaces/$Workspace/providers/Microsoft.SecurityInsights/alertRules?api-version=2019-01-01-preview"

        if ($SettingsFile.Extension -eq '.json') {
            try {
                $analytics = (Get-Content $SettingsFile -Raw | ConvertFrom-Json -ErrorAction Stop).analytics
                Write-Verbose -Message "Found $($analytics.count) rules"
            } catch {
                Write-Verbose $_
                Write-Error -Message 'Unable to convert JSON file' -ErrorAction Stop
            }
        } elseif ($SettingsFile.Extension -in '.yaml', 'yml') {
            try {
                $analytics = [pscustomobject](Get-Content $SettingsFile -Raw | ConvertFrom-Yaml -ErrorAction Stop) | Add-Member -MemberType AliasProperty -Name DisplayName -Value name -PassThru
                Write-Verbose -Message 'Found compatibel yaml file'
            } catch {
                Write-Verbose $_
                Write-Error -Message 'Unable to convert yaml file' -ErrorAction Stop
            }
        }

        foreach ($item in $analytics) {
            Write-Verbose -Message "Started with rule: $($item.displayName)"

            $guid = (New-Guid).Guid

            try {
                Write-Verbose -Message 'Getting all current Analytic rules'
                $contents = Invoke-WebRequest -Uri $getUri -Method Get -Headers $script:authHeader -UseBasicParsing -ErrorAction Stop
                $content = ($contents.Content | ConvertFrom-Json).value | Where-Object { $_.properties.displayName -eq $item.displayName }

                if ($content) {
                    Write-Verbose -Message "Rule $($item.displayName) exists in Azure Sentinel"

                    $item | Add-Member -NotePropertyName name -NotePropertyValue $content.name -Force
                    $item | Add-Member -NotePropertyName etag -NotePropertyValue $content.etag -Force
                    $item | Add-Member -NotePropertyName Id -NotePropertyValue $content.id -Force

                    $uri = "https://management.azure.com/subscriptions/$Subscription/resourceGroups/$ResourceGroup/providers/Microsoft.OperationalInsights/workspaces/$Workspace/providers/Microsoft.SecurityInsights/alertRules/$($content.name)?api-version=2019-01-01-preview"
                } else {
                    Write-Verbose -Message "Rule $($item.displayName) doesn't exists in Azure Sentinel"

                    $item | Add-Member -NotePropertyName name -NotePropertyValue $guid -Force
                    $item | Add-Member -NotePropertyName etag -NotePropertyValue $null -Force
                    $item | Add-Member -NotePropertyName Id -NotePropertyValue "/subscriptions/$Subscription/resourceGroups/$ResourceGroup/providers/Microsoft.OperationalInsights/workspaces/$Workspace/providers/Microsoft.SecurityInsights/alertRules/$guid" -Force

                    $uri = "https://management.azure.com/subscriptions/$Subscription/resourceGroups/$ResourceGroup/providers/Microsoft.OperationalInsights/workspaces/$Workspace/providers/Microsoft.SecurityInsights/alertRules/$($guid)?api-version=2019-01-01-preview"
                }
            } catch {
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
            } catch {
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
                            $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json)
                            Write-Output $result.StatusDescription
                        } catch {
                            $errorReturn = $_
                            $errorResult = ($errorReturn | ConvertFrom-Json ).error
                            Write-Verbose $_.Exception.Message
                            Write-Error "Unable to invoke webrequest with error message: $($errorResult.message)" -ErrorAction Stop
                        }
                    } else {
                        Write-Output "No change have been made for rule $($item.displayName), deployment aborted"
                    }
                }
            } else {
                Write-Verbose "Creating new rule: $($item.displayName)"

                try {
                    $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json)
                    Write-Output $result.StatusDescription
                } catch {
                    $errorReturn = $_
                    $errorResult = ($errorReturn | ConvertFrom-Json ).error
                    Write-Verbose $_.Exception.Message
                    Write-Error "Unable to invoke webrequest with error message: $($errorResult.message)" -ErrorAction Stop
                }
            }
        }
    }
}

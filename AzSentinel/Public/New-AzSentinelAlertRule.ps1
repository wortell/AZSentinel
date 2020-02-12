#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function New-AzSentinelAlertRule {
    <#
    .SYNOPSIS
    Create Azure Sentinal Alert Rules
    .DESCRIPTION
    Use this function creates Azure Sentinal Alert rules from provided CMDLET
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER WorkspaceName
    Enter the Workspace name
    .PARAMETER DisplayName
    Enter the Display name for the Alert rule
    .PARAMETER Description
    Enter the Description for the Alert rule
    .PARAMETER Severity
    Enter the Severity, valid values: Medium", "High", "Low", "Informational"
    .PARAMETER Enabled
    Set $true to enable the Alert Rule or $false to disable Alert Rule
    .PARAMETER Query
    Enter the Query that you want to use
    .PARAMETER QueryFrequency
    Enter the query frequency, example: 5H or 5M (H stands for Hour and M stands for Minute)
    .PARAMETER QueryPeriod
    Enter the quury period, exmaple: 5H or 5M (H stands for Hour and M stands for Minute)
    .PARAMETER TriggerOperator
    Select the triggert Operator, valid values are: "GreaterThan", "FewerThan", "EqualTo", "NotEqualTo"
    .PARAMETER TriggerThreshold
    Enter the trigger treshold
    .PARAMETER SuppressionDuration
    Enter the suppression duration, example: 5H or 5M (H stands for Hour and M stands for Minute)
    .PARAMETER SuppressionEnabled
    Set $true to enable Suppression or $false to disable Suppression
    .PARAMETER Tactics
    Enter the Tactics, valid values: "InitialAccess", "Persistence", "Execution", "PrivilegeEscalation", "DefenseEvasion", "CredentialAccess", "LateralMovement", "Discovery", "Collection", "Exfiltration", "CommandAndControl", "Impact"
    .EXAMPLE
    New-AzSentinelAlertRule -WorkspaceName "" -DisplayName "" -Description "" -Severity -Enabled $true -Query '' -QueryFrequency "" -QueryPeriod "" -TriggerOperator -TriggerThreshold  -SuppressionDuration "" -SuppressionEnabled $false -Tactics @("","")
    In this example you create a new Alert rule by defining the rule properties from CMDLET
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
        [string] $Description,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Severity] $Severity,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [bool] $Enabled,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Query,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $QueryFrequency,

        [ValidateNotNullOrEmpty()]
        [string] $QueryPeriod,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [TriggerOperator] $TriggerOperator,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Int] $TriggerThreshold,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $SuppressionDuration,

        [Parameter(Mandatory)]
        [bool] $SuppressionEnabled,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [Tactics[]] $Tactics,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [string] $PlaybookName = $null
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

        Write-Verbose -Message "Creating new rule: $($DisplayName)"
        try {
            Write-Verbose -Message "Get rule $DisplayName"
            $content = Get-AzSentinelAlertRule @arguments -RuleName $DisplayName -ErrorAction SilentlyContinue

            if ($content) {
                Write-Verbose -Message "Rule $($DisplayName) exists in Azure Sentinel"

                $item | Add-Member -NotePropertyName name -NotePropertyValue $content.name -Force
                $item | Add-Member -NotePropertyName etag -NotePropertyValue $content.eTag -Force
                $item | Add-Member -NotePropertyName Id -NotePropertyValue $content.id -Force

                $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/alertRules/$($content.name)?api-version=2019-01-01-preview"
            }
            else {
                Write-Verbose -Message "Rule $($DisplayName) doesn't exists in Azure Sentinel"

                $guid = (New-Guid).Guid

                $item | Add-Member -NotePropertyName name -NotePropertyValue $guid -Force
                $item | Add-Member -NotePropertyName etag -NotePropertyValue $null -Force
                $item | Add-Member -NotePropertyName Id -NotePropertyValue "$script:Workspace/providers/Microsoft.SecurityInsights/alertRules/$guid" -Force

                $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/alertRules/$($guid)?api-version=2019-01-01-preview"
            }
        }
        catch {
            Write-Verbose $_
            Write-Error "Unable to connect to APi to get Analytic rules with message: $($_.Exception.Message)" -ErrorAction Stop
        }

        try {
            $bodyAlertProp = [AlertProp]::new(
                $item.name,
                $DisplayName,
                $Description,
                $Severity,
                $Enabled,
                $Query,
                $QueryFrequency,
                $QueryPeriod,
                $TriggerOperator,
                $TriggerThreshold,
                $SuppressionDuration,
                $SuppressionEnabled,
                $Tactics,
                $PlaybookName
            )
            $body = [AlertRule]::new( $item.name, $item.etag, $bodyAlertProp, $item.Id)
        }
        catch {
            Write-Error "Unable to initiate class with error: $($_.Exception.Message)" -ErrorAction Stop
        }

        if ($content) {
            $compareResult = Compare-Policy -ReferenceTemplate ($content | Select-Object * -ExcludeProperty lastModifiedUtc, alertRuleTemplateName, name, etag, id) -DifferenceTemplate ($body.Properties | Select-Object * -ExcludeProperty name)
            if ($compareResult) {
                Write-Output "Found Differences for rule: $($DisplayName)"
                Write-Output ($compareResult | Format-Table | Out-String)

                if ($PSCmdlet.ShouldProcess("Do you want to update profile: $($body.Properties.DisplayName)")) {
                    try {
                        $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json -EnumsAsStrings)

                        if ($compareResult.PropertyName -contains "playbookName") {
                            #New-AzSentinelAlertRuleAction @arguments -PlayBookName $(($body.Properties).playbookName) -RuleId $($body.Name) -Confirm:$false
                            New-AzSentinelAlertRuleAction @arguments -PlayBookName 'pkmsentinel' -RuleId 'b6103d42-d2fb-4f35-bced-c76a7f31ee4e' -Confirm:$false
                        }
                        elseif ($null -ne $content.playbookName -and $null -eq $body.Properties.playbookName) {
                            Write-Host "Currently Playbook configured but will be removed now"
                        }

                        Write-Output "Successfully updated rule: $($DisplayName) with status: $($result.StatusDescription)"
                        Write-Output ($body.Properties | Format-List | Format-Table | Out-String)
                    }
                    catch {
                        Write-Verbose $_
                        Write-Error "Unable to invoke webrequest with error message: $($_.Exception.Message)" -ErrorAction Stop
                    }
                }
                else {
                    Write-Output "No change have been made for rule $($DisplayName), deployment aborted"
                }
            }
            else {
                Write-Output "Rule $($DisplayName) is compliance, nothing to do"
                Write-Output ($body.Properties | Format-List | Format-Table | Out-String)
            }
        }
        else {
            Write-Verbose "Creating new rule: $($DisplayName)"

            try {
                $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json -EnumsAsStrings)

                if ($body.Properties.playbookName) {
                    New-AzSentinelAlertRuleAction -PlayBookName $($body.Properties.playbookName) -RuleName $($body.Properties.DisplayName) -confirm:$false
                }

                Write-Output "Successfully created rule: $($DisplayName) with status: $($result.StatusDescription)"
                Write-Output ($body.Properties | Format-List | Format-Table | Out-String)
            }
            catch {
                Write-Verbose $_
                Write-Error "Unable to invoke webrequest with error message: $($_.Exception.Message)" -ErrorAction Stop
            }
        }
    }
}

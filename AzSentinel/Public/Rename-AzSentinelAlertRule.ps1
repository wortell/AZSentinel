#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Rename-AzSentinelAlertRule {
    <#
      .SYNOPSIS
      Rename Azure Sentinel Alert Rule
      .DESCRIPTION
      With this function you can rename Azure Sentinel Alert rule
      .PARAMETER SubscriptionId
      Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
      .PARAMETER WorkspaceName
      Enter the Workspace name
      .PARAMETER CurrentRuleName
      Enter the current name of the Alert rule
      .PARAMETER NewRuleName
      Enter the new name of the Alert rule
      .EXAMPLE
      Rename-AzSentinelAlertRule -WorkspaceName "" -CurrentRuleName "" -NewRuleName ""
      In this example you can rename the alert rule
    #>

    [cmdletbinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $false,
            ParameterSetName = "Sub")]
        [ValidateNotNullOrEmpty()]
        [string] $SubscriptionId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $true,
            ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$CurrentRuleName,

        [Parameter(Mandatory = $true,
            ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$NewRuleName
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

        try {
            $rule = Get-AzSentinelAlertRule @arguments -RuleName $CurrentRuleName -ErrorAction Stop

            $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/alertRules/$($currentRule.name)?api-version=2019-01-01-preview"

            $rule.displayName = $NewRuleName

            $bodyAlertProp = [AlertProp]::new(
                ($rule | Select-Object * -ExcludeProperty lastModifiedUtc, etag, id)
            )

            $body = [AlertRule]::new(
                ($rule | Select-Object lastModifiedUtc, etag, id, name),
                $bodyAlertProp
            )

            try {
                $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($body | ConvertTo-Json -EnumsAsStrings)
                $return = "Successfully renamed rule $($CurrentRuleName) to $($NewRuleName) with status: $($result.StatusDescription)"
                return $return
            }
            catch {
                $return = $_.Exception.Message
                Write-Error "Rename failed with error $return"
            }
        }
        catch {
            $return = $_.Exception.Message
            Write-Error $return
        }
    }
}

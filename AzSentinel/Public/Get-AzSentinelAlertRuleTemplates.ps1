#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Get-AzSentinelAlertRuleTemplates {
    <#
      .SYNOPSIS
      Get Azure Sentinel Alert Rules Templates
      .DESCRIPTION
      With this function you can get the configuration of the Azure Sentinel Alert Rules Templates from Azure Sentinel
      .PARAMETER SubscriptionId
      Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
      .PARAMETER WorkspaceName
      Enter the Workspace name
      .EXAMPLE
      Get-AzSentinelAlertRuleTemplates -WorkspaceName ""
      In this example you can get Sentinel alert rules templates in once
    #>

    [cmdletbinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $false,
            ParameterSetName = "Sub")]
        [ValidateNotNullOrEmpty()]
        [string] $SubscriptionId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceName
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

        $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/alertRuleTemplates?api-version=2019-01-01-preview"

        Write-Verbose -Message "Using URI: $($uri)"

        try {
            $alertRulesTemplates = Invoke-RestMethod -Uri $uri -Method Get -Headers $script:authHeader
        }
        catch {
            Write-Verbose $_
            Write-Error "Unable to get alert rules with error code: $($_.Exception.Message)" -ErrorAction Stop
        }

        $return = @()

        if ($alertRulesTemplates.value) {
            Write-Verbose "Found $($alertRulesTemplates.value.count) Alert rules templates"

            # This returns the objects for the alert rule templates which contains id, name, type, kind and properties[severity, query, ...]
            # $alertRulesTemplates.Value | ForEach-Object {
            #     $return += $_.properties
            # }
            $return =  $alertRulesTemplates.value
            return  $return
        }
        else {
            Write-Warning "No rules templates found on $($WorkspaceName)"
        }
    }
}

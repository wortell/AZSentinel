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
      .PARAMETER Kind
      Enter the Kind to filter on the templates
      .EXAMPLE
      Get-AzSentinelAlertRuleTemplates -WorkspaceName ""
      In this example you can get Sentinel alert rules templates in once
      .EXAMPLE
      Get-AzSentinelAlertRuleTemplates -WorkspaceName "" -Kind Fusion, MicrosoftSecurityIncidentCreation
      Filter on the Kind
    #>

    param (
        [Parameter(Mandatory = $false,
            ParameterSetName = "Sub")]
        [ValidateNotNullOrEmpty()]
        [string] $SubscriptionId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Kind[]]$Kind
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
            Get-LogAnalyticWorkspace @arguments -ErrorAction Stop
        }
        catch {
            Write-Error $_.Exception.Message
            break
        }

        $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/alertRuleTemplates?api-version=2019-01-01-preview"

        Write-Verbose -Message "Using URI: $($uri)"

        try {
            $alertRulesTemplates = (Invoke-RestMethod -Uri $uri -Method Get -Headers $script:authHeader).value
        }
        catch {
            Write-Verbose $_
            Write-Error "Unable to get alert rules with error code: $($_.Exception.Message)" -ErrorAction Stop
        }

        $return = @()

        if ($alertRulesTemplates) {
            Write-Verbose "Found $($alertRulesTemplates.count) Alert rules templates"

            if ($Kind) {
                foreach ($item in $Kind) {
                    $alertRulesTemplates | Where-Object Kind -eq $item | ForEach-Object {
                        $_.properties | Add-Member -NotePropertyName name -NotePropertyValue $_.name -Force
                        $_.properties | Add-Member -NotePropertyName id -NotePropertyValue $_.id -Force
                        $_.properties | Add-Member -NotePropertyName kind -NotePropertyValue $_.kind -Force

                        $return += $_.properties
                    }
                }
            }
            else {
                $alertRulesTemplates | ForEach-Object {
                    $_.properties | Add-Member -NotePropertyName name -NotePropertyValue $_.name -Force
                    $_.properties | Add-Member -NotePropertyName id -NotePropertyValue $_.id -Force
                    $_.properties | Add-Member -NotePropertyName kind -NotePropertyValue $_.kind -Force

                    $return += $_.properties
                }
            }

            return $return

        }
        else {
            Write-Host "No rules templates found on $($WorkspaceName)"
        }
    }
}

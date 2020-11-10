#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Remove-AzSentinelAlertRule {
    <#
    .SYNOPSIS
    Remove Azure Sentinal Alert Rules
    .DESCRIPTION
    With this function you can remove Azure Sentinal Alert rules from Powershell, if you don't provide andy Rule name all rules will be removed
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER WorkspaceName
    Enter the Workspace name
    .PARAMETER RuleName
    Enter the name of the rule that you wnat to remove
    .EXAMPLE
    Remove-AzSentinelAlertRule -WorkspaceName "" -RuleName ""
    In this example the defined rule will be removed from Azure Sentinel
    .EXAMPLE
    Remove-AzSentinelAlertRule -WorkspaceName "" -RuleName "","", ""
    In this example you can define multiple rules that will be removed
    .EXAMPLE
    Remove-AzSentinelAlertRule -WorkspaceName ""
    In this example no rule is specified, all rules will be removed one by one. For each rule you need to confirm the action
    #>

    [cmdletbinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $false,
            ParameterSetName = "Sub")]
        [ValidateNotNullOrEmpty()]
        [string] $SubscriptionId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $false,
            ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string[]]$RuleName
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

        if ($RuleName) {
            # remove defined rules
            foreach ($rule in $RuleName) {

                try {
                    $item = Get-AzSentinelAlertRule @arguments -RuleName $rule -WarningAction SilentlyContinue -ErrorAction Stop
                }
                catch {
                    $return = $_.Exception.Message
                    Write-Error $return
                }

                if ($item) {
                    $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/alertRules/$($item.name)?api-version=2019-01-01-preview"

                    if ($PSCmdlet.ShouldProcess("Do you want to remove: $rule")) {
                        Write-Output $item
                        try {
                            $result = Invoke-WebRequest -Uri $uri -Method DELETE -Headers $script:authHeader
                            Write-Output "Successfully removed rule: $($rule) with status: $($result.StatusDescription)"
                        }
                        catch {
                            Write-Verbose $_
                            Write-Error "Unable to remove rule: $($rule) with error message: $($_.Exception.Message)" -ErrorAction Continue
                        }
                    }
                    else {
                        Write-Output "No change have been made for rule: $rule"
                    }
                }
                else {
                    Write-Warning "$rule not found in $WorkspaceName"
                }
            }
        }
        else {
            Write-Warning "No Rule selected, All rules will be removed one by one!"
            Get-AzSentinelAlertRule @arguments | ForEach-Object {
                $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/alertRules/$($_.name)?api-version=2019-01-01-preview"

                if ($PSCmdlet.ShouldProcess("Do you want to remove: $($_.displayName)")) {
                    try {
                        $result = Invoke-WebRequest -Uri $uri -Method DELETE -Headers $script:authHeader
                        Write-Output "Successfully removed rule: $($_.displayName) with status: $($result.StatusDescription)"
                    }
                    catch {
                        Write-Verbose $_
                        Write-Error "Unable to remove rule: $($_.displayName) with error message: $($_.Exception.Message)" -ErrorAction Continue
                    }
                }
                else {
                    Write-Output "No change have been made for rule: $($_.displayName)"
                }
            }
        }
    }
}

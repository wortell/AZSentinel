#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Remove-AzSentinelHuntingRule {
    <#
    .SYNOPSIS
    Remove Azure Sentinal Hunting Rules
    .DESCRIPTION
    With this function you can remove Azure Sentinal hunting rules from Powershell, if you don't provide andy Hunting rule name all rules will be removed
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER WorkspaceName
    Enter the Workspace name
    .PARAMETER RuleName
    Enter the name of the rule that you wnat to remove
    .EXAMPLE
    Remove-AzSentinelHuntingRule -WorkspaceName "" -RuleName ""
    In this example the defined hunting rule will be removed from Azure Sentinel
    .EXAMPLE
    Remove-AzSentinelHuntingRule -WorkspaceName "" -RuleName "","", ""
    In this example you can define multiple hunting rules that will be removed
    .EXAMPLE
    Remove-AzSentinelHuntingRule -WorkspaceName ""
    In this example no hunting rule is specified, all hunting rules will be removed one by one. For each rule you need to confirm the action
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
                    $item = Get-AzSentinelHuntingRule @arguments -RuleName $rule -ErrorAction Stop
                }
                catch {
                    Write-Error $_.Exception.Message
                    break
                }

                if ($item) {
                    $uri = "$script:baseUri/savedSearches/$($item.name)?api-version=2017-04-26-preview"

                    if ($PSCmdlet.ShouldProcess("Do you want to remove: $rule")) {
                        Write-Output $item
                        try {
                            $result = Invoke-WebRequest -Uri $uri -Method DELETE -Headers $script:authHeader
                            Write-Output "Successfully removed hunting rule: $($rule) with status: $($result.StatusDescription)"
                        }
                        catch {
                            Write-Verbose $_
                            Write-Error "Unable to remove rule: $($rule) with error message: $($_.Exception.Message)" -ErrorAction Continue
                        }
                    }
                    else {
                        Write-Output "No change have been made for hunting rule: $rule"
                    }
                }
                else {
                    Write-Warning "Hunting rule $rule not found in $WorkspaceName"
                }
            }
        }
        else {
            Write-Warning "No hunting rule selected, All hunting rules will be removed one by one!"
            Get-AzSentinelHuntingRule @arguments -Filter "Hunting Queries" | ForEach-Object {
                $uri = "$script:baseUri/savedSearches/$($_.name)?api-version=2017-04-26-preview"
                if ($PSCmdlet.ShouldProcess("Do you want to remove: $($_.displayName)")) {
                    try {
                        $result = Invoke-WebRequest -Uri $uri -Method DELETE -Headers $script:authHeader
                        Write-Output "Successfully removed hunting rule: $($_.displayName) with status: $($result.StatusDescription)"
                    }
                    catch {
                        Write-Verbose $_
                        Write-Error "Unable to remove rule: $($_.displayName) with error message: $($_.Exception.Message)" -ErrorAction Continue
                    }
                }
                else {
                    Write-Output "No change have been made for hunting rule: $($_.displayName)"
                }
            }
        }
    }
}

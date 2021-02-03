function Export-AzSentinel {
    <#
      .SYNOPSIS
      Export Azure Sentinel
      .DESCRIPTION
      With this function you can export Azure Sentinel configuration
      .PARAMETER SubscriptionId
      Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
      .PARAMETER WorkspaceName
      Enter the Workspace name
      .PARAMETER Kind
      Select what you want to export: Alert, Hunting, Templates or All
      .PARAMETER OutputFolder
      The Path where you want to export the JSON files
      .PARAMETER TemplatesKind
      Select which Kind of templates you want to export, if empy all Templates will be exported
      .EXAMPLE
      Export-AzSentinel -WorkspaceName '' -Path C:\Temp\ -Kind All
      In this example you export Alert, Hunting and Template rules
      .EXAMPLE
      Export-AzSentinel -WorkspaceName '' -Path C:\Temp\ -Kind Templates
      In this example you export only the Templates
      .EXAMPLE
      Export-AzSentinel -WorkspaceName '' -Path C:\Temp\ -Kind Alert
      In this example you export only the Scheduled Alert rules
    #>

    param (
        [Parameter(Mandatory = $false,
            ParameterSetName = "Sub")]
        [ValidateNotNullOrEmpty()]
        [string] $SubscriptionId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceName,

        [Parameter(Mandatory)]
        [System.IO.FileInfo]$OutputFolder,

        [Parameter(Mandatory,
            ValueFromPipeline)]
        [ExportType[]]$Kind,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Kind[]]$TemplatesKind
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

        $date = Get-Date -Format HHmmss_ddMMyyyy

        <#
        Test export path
        #>
        if (Test-Path $OutputFolder) {
            Write-Verbose "Path Exists"
        }
        else {
            try {
                $null = New-Item -Path $OutputFolder -Force -ItemType Directory -ErrorAction Stop
            }
            catch {
                $ErrorMessage = $_.Exception.Message
                Write-Error $ErrorMessage
                Write-Verbose $_
                Break
            }
        }

        <#
        Export Alert rules section
        #>
        if (($Kind -like 'Alert') -or ($Kind -like 'All')) {

            try {
                $rules = Get-AzSentinelAlertRule @arguments -ErrorAction Stop
            }
            catch {
                $return = $_.Exception.Message
                Write-Error $return
            }

            if ($rules) {
                $output = @{
                    Scheduled                         = @(
                        $rules | Where-Object kind -eq Scheduled
                    )
                    Fusion                            = @(
                        $rules | Where-Object kind -eq Fusion
                    )
                    MLBehaviorAnalytics               = @(
                        $rules | Where-Object kind -eq MLBehaviorAnalytics
                    )
                    MicrosoftSecurityIncidentCreation = @(
                        $rules | Where-Object kind -eq MicrosoftSecurityIncidentCreation
                    )
                }

                try {
                    $fullPath = "$($OutputFolder)AlertRules_$date.json"
                    $output | ConvertTo-Json -EnumsAsStrings -Depth 15 | Out-File $fullPath -ErrorAction Stop
                    Write-Output "Alert rules exported to: $fullPath"
                }
                catch {
                    $ErrorMessage = $_.Exception.Message
                    Write-Error $ErrorMessage
                    Write-Verbose $_
                    Break
                }
            }
        }

        <#
        Export Hunting rules section
        #>
        if (($Kind -like 'Hunting') -or ($Kind -like 'All')) {
            try {
                $rules = Get-AzSentinelHuntingRule @arguments -ErrorAction Stop
            }
            catch {
                $return = $_.Exception.Message
                Write-Error $return
            }
            if ($rules) {
                $output = @{
                    Hunting = @()
                }
                $output.Hunting += $rules
                try {
                    $fullPath = "$($OutputFolder)HuntingRules_$date.json"
                    $output | ConvertTo-Json -EnumsAsStrings -Depth 15 | Out-File $fullPath -ErrorAction Stop
                    Write-Output "Hunting rules exported to: $fullPath"
                }
                catch {
                    $ErrorMessage = $_.Exception.Message
                    Write-Error $ErrorMessage
                    Write-Verbose $_
                    Break
                }
            }
        }

        <#
        Export Templates section
        #>
        if (($Kind -like 'Templates') -or ($Kind -like 'All')) {

            if ($TemplatesKind) {
                try {
                    $templates = Get-AzSentinelAlertRuleTemplates @arguments -Kind $TemplatesKind
                }
                catch {
                    $return = $_.Exception.Message
                    Write-Error $return
                }
            }
            else {
                try {
                    $templates = Get-AzSentinelAlertRuleTemplates @arguments
                }
                catch {
                    $return = $_.Exception.Message
                    Write-Error $return
                }
            }

            if ($templates) {
                $output = @{
                    Scheduled                         = @(
                        $templates | Where-Object kind -eq Scheduled
                    )
                    Fusion                            = @(
                        $templates | Where-Object kind -eq Fusion
                    )
                    MLBehaviorAnalytics               = @(
                        $templates | Where-Object kind -eq MLBehaviorAnalytics
                    )
                    MicrosoftSecurityIncidentCreation = @(
                        $templates | Where-Object kind -eq MicrosoftSecurityIncidentCreation
                    )
                }

                try {
                    $fullPath = "$($OutputFolder)Templates_$date.json"
                    $output | ConvertTo-Json -EnumsAsStrings -Depth 15 | Out-File $fullPath -ErrorAction Stop
                    Write-Output "Templates exported to: $fullPath"
                }
                catch {
                    $ErrorMessage = $_.Exception.Message
                    Write-Error $ErrorMessage
                    Write-Verbose $_
                    Break
                }
            }
        }
    }
}

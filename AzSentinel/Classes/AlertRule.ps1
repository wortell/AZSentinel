class AlertProp {

    [guid] $Name

    [string] $DisplayName

    [string] $Description

    [Severity] $Severity

    [bool] $Enabled

    [string] $Query

    [string] $QueryFrequency

    [string] $QueryPeriod

    [TriggerOperator]$TriggerOperator

    [Int] $TriggerThreshold

    [string] $SuppressionDuration

    [bool] $SuppressionEnabled

    [Tactics[]] $Tactics

    [string] $PlaybookName

    static [string] TriggerOperatorSwitch([string]$value) {
        switch ($value) {
            "gt" { $value = "GreaterThan" }
            "lt" { $value = "LessThan" }
            "eq" { $value = "Equal" }
            "ne" { $value = "NotEqual" }
            default { $value }
        }
        return $value
    }

    AlertProp ($Name, $DisplayName, $Description, $Severity, $Enabled, $Query, $QueryFrequency, $QueryPeriod, $TriggerOperator, $TriggerThreshold, $suppressionDuration, $suppressionEnabled, $Tactics, $PlaybookName) {
        $this.name = $Name
        $this.DisplayName = $DisplayName
        $this.Description = $Description
        $this.Severity = $Severity
        $this.Enabled = $Enabled
        $this.Query = $Query
        $this.QueryFrequency = if ($QueryFrequency -like "PT*") { $QueryFrequency.ToUpper() } else { ("PT" + $QueryFrequency).ToUpper() }
        $this.QueryPeriod = if ($QueryPeriod -like "PT*") { $QueryPeriod.ToUpper() } else { ("PT" + $QueryPeriod).ToUpper() }
        $this.TriggerOperator = [AlertProp]::TriggerOperatorSwitch($TriggerOperator)
        $this.TriggerThreshold = $TriggerThreshold
        $this.SuppressionDuration = if ((! $null -eq $suppressionDuration) -or ( $false -eq $suppressionEnabled)) { if ($suppressionDuration -like "PT*") { $suppressionDuration.ToUpper() } else { ("PT" + $suppressionDuration).ToUpper() } } else { "PT1H" }
        $this.SuppressionEnabled = if ($suppressionEnabled) { $suppressionEnabled } else { $false }
        $this.Tactics = $Tactics
        $this.PlaybookName = $PlaybookName
    }
}

class AlertRule {
    [guid] $Name

    [string] $Etag

    [string]$type

    [AlertProp]$Properties

    [Parameter(Mandatory)]
    [string]$Id

    AlertRule ([guid]$Name, [string]$Etag, [AlertProp]$Properties, $Id) {

        $this.id = $Id
        $this.type = 'Microsoft.SecurityInsights/alertRules'
        $this.Name = $Name
        $this.Etag = $Etag
        $this.Properties = $Properties
    }
}

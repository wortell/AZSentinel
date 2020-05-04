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

    hidden $properties

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

    # Convert string to ISO_8601 format PdDThHmMsS
    static [string] TimeString([string]$value) {
        $value = $value.ToUpper()
        # Return values already in ISO 8601 format
        if ($value -match "PT.*|P.*D") {
            return $value
        }
        # Format day time periods
        if ($value -like "*D") {
            return "P$value"
        }
        # Format hour and minute time periods
        if ($value -match ".*[HM]") {
            return "PT$value"
        }
        return $value
    }
    AlertProp ($properties) {
        $this.name = $properties.Name
        $this.DisplayName = $properties.DisplayName
        $this.Description = $properties.Description
        $this.Severity = $properties.Severity
        $this.Enabled = $properties.Enabled
        $this.Query = $properties.Query
        $this.QueryFrequency = $properties.QueryFrequency
        $this.QueryPeriod = $properties.QueryPeriod
        $this.TriggerOperator = $properties.TriggerOperator
        $this.TriggerThreshold = $properties.TriggerThreshold
        $this.SuppressionDuration = $properties.SuppressionDuration
        $this.SuppressionEnabled = $properties.SuppressionEnabled
        $this.Tactics = $properties.Tactics
        $this.PlaybookName = $properties.PlaybookName
    }

    AlertProp ($Name, $DisplayName, $Description, $Severity, $Enabled, $Query, $QueryFrequency, $QueryPeriod, $TriggerOperator, $TriggerThreshold, $suppressionDuration, $suppressionEnabled, $Tactics, $PlaybookName) {
        $this.name = $Name
        $this.DisplayName = $DisplayName
        $this.Description = $Description
        $this.Severity = $Severity
        $this.Enabled = $Enabled
        $this.Query = $Query
        $this.QueryFrequency = [AlertProp]::TimeString($QueryFrequency)
        $this.QueryPeriod = [AlertProp]::TimeString($QueryPeriod)
        $this.TriggerOperator = [AlertProp]::TriggerOperatorSwitch($TriggerOperator)
        $this.TriggerThreshold = $TriggerThreshold
        $this.SuppressionDuration = if ((! $null -eq $suppressionDuration) -or ( $false -eq $suppressionEnabled)) { [AlertProp]::TimeString($suppressionDuration) } else { "PT1H" }
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

    [string]$Id

    $header

    AlertRule($header, $properties) {
        $this.id = $header.Id
        $this.type = 'Microsoft.SecurityInsights/alertRules'
        $this.Name = $header.Name
        $this.Etag = $header.Etag
        $this.Properties = $properties
    }

    AlertRule ([guid]$Name, [string]$Etag, [AlertProp]$Properties, $Id) {

        $this.id = $Id
        $this.type = 'Microsoft.SecurityInsights/alertRules'
        $this.Name = $Name
        $this.Etag = $Etag
        $this.Properties = $Properties
    }
}

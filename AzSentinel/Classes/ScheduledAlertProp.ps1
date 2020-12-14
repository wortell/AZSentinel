class ScheduledAlertProp {

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

    [IncidentConfiguration]$IncidentConfiguration

    $eventGroupingSettings

    [string] $AlertRuleTemplateName

    hidden [AggregationKind]$aggregationKind

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
    ScheduledAlertProp (){

    }

    ScheduledAlertProp ($Name, $DisplayName, $Description, $Severity, $Enabled, $Query, $QueryFrequency, `
            $QueryPeriod, $TriggerOperator, $TriggerThreshold, $suppressionDuration, `
            $suppressionEnabled, $Tactics, $PlaybookName, $IncidentConfiguration, $aggregationKind) {
        $this.name = $Name
        $this.DisplayName = $DisplayName
        $this.Description = $Description
        $this.Severity = $Severity
        $this.Enabled = $Enabled
        $this.Query = $Query
        $this.QueryFrequency = [ScheduledAlertProp]::TimeString($QueryFrequency)
        $this.QueryPeriod = [ScheduledAlertProp]::TimeString($QueryPeriod)
        $this.TriggerOperator = [ScheduledAlertProp]::TriggerOperatorSwitch($TriggerOperator)
        $this.TriggerThreshold = $TriggerThreshold
        $this.SuppressionDuration = if (($null -eq $suppressionDuration) -or ( $false -eq $suppressionEnabled)) {
            "PT1H"
        }
        else {
            if ( [ScheduledAlertProp]::TimeString($suppressionDuration) -ge [ScheduledAlertProp]::TimeString($QueryFrequency) ) {
                [ScheduledAlertProp]::TimeString($suppressionDuration)
            }
            else {
                Write-Error "Invalid Properties for Scheduled alert rule: 'suppressionDuration' should be greater than or equal to 'queryFrequency'" -ErrorAction Stop
            }
        }
        $this.SuppressionEnabled = if ($suppressionEnabled) { $suppressionEnabled } else { $false }
        $this.Tactics = $Tactics
        if ($PlaybookName) {
            $this.PlaybookName = if ($PlaybookName.Split('/').count -gt 1){
                $PlaybookName.Split('/')[-1]
            } else {
                $PlaybookName
            }
        }
        $this.IncidentConfiguration = $IncidentConfiguration
        $this.eventGroupingSettings = @{
            aggregationKind = if ($aggregationKind) { $aggregationKind } else { "SingleAlert" }
        }
    }

    ScheduledAlertProp ($Name, $DisplayName, $Description, $Severity, $Enabled, $Query, $QueryFrequency, `
            $QueryPeriod, $TriggerOperator, $TriggerThreshold, $suppressionDuration, `
            $suppressionEnabled, $Tactics, $PlaybookName, $IncidentConfiguration, `
            $aggregationKind, $AlertRuleTemplateName) {
        $this.name = $Name
        $this.DisplayName = $DisplayName
        $this.Description = $Description
        $this.Severity = $Severity
        $this.Enabled = $Enabled
        $this.Query = $Query
        $this.QueryFrequency = [ScheduledAlertProp]::TimeString($QueryFrequency)
        $this.QueryPeriod = [ScheduledAlertProp]::TimeString($QueryPeriod)
        $this.TriggerOperator = [ScheduledAlertProp]::TriggerOperatorSwitch($TriggerOperator)
        $this.TriggerThreshold = $TriggerThreshold
        $this.SuppressionDuration = if (($null -eq $suppressionDuration) -or ( $false -eq $suppressionEnabled)) {
            "PT1H"
        }
        else {
            if ( [ScheduledAlertProp]::TimeString($suppressionDuration) -ge [ScheduledAlertProp]::TimeString($QueryFrequency) ) {
                [ScheduledAlertProp]::TimeString($suppressionDuration)
            }
            else {
                Write-Error "Invalid Properties for Scheduled alert rule: 'suppressionDuration' should be greater than or equal to 'queryFrequency'" -ErrorAction Stop
            }
        }
        $this.SuppressionEnabled = if ($suppressionEnabled) { $suppressionEnabled } else { $false }
        $this.Tactics = $Tactics
        if ($PlaybookName) {
            $this.PlaybookName = if ($PlaybookName.Split('/').count -gt 1){
                $PlaybookName.Split('/')[-1]
            } else {
                $PlaybookName
            }
        }
        $this.IncidentConfiguration = $IncidentConfiguration
        $this.eventGroupingSettings = @{
            aggregationKind = if ($aggregationKind) { $aggregationKind } else { "SingleAlert" }
        }
        $this.AlertRuleTemplateName  = $AlertRuleTemplateName
    }
}

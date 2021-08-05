class alertDetailsOverride {
    [string]$alertDisplayNameFormat
    [string]$alertDescriptionFormat
    [string]$alertTacticsColumnName
    [string]$alertSeverityColumnName

    alertDetailsOverride () {
        $this.alertDisplayNameFormat
        $this.alertDescriptionFormat
        $this.alertTacticsColumnName
        $this.alertSeverityColumnName
    }

    alertDetailsOverride ($alertDisplayNameFormat, $alertDescriptionFormat, $alertTacticsColumnName, $alertSeverityColumnName ) {
        if ($alertDisplayNameFormat) { $this.alertDisplayNameFormat = $alertDisplayNameFormat } else { $this.alertDisplayNameFormat }
        if ($alertDescriptionFormat) { $this.alertDescriptionFormat = $alertDescriptionFormat } else { $this.alertDescriptionFormat }
        if ($alertTacticsColumnName) { $this.alertTacticsColumnName = $alertTacticsColumnName } else { $this.alertTacticsColumnName }
        if ($alertSeverityColumnName) { $this.alertSeverityColumnName = $alertSeverityColumnName } else { $this.alertSeverityColumnName }
    }
}

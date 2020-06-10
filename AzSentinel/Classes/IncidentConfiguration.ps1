class IncidentConfiguration {
    [bool] $CreateIncident

    $GroupingConfiguration

    IncidentConfiguration ($CreateIncident, [PSCustomObject]$GroupingConfiguration) {
        $this.createIncident = if ($createIncident) { $createIncident } else { $true }
        $this.groupingConfiguration = [PSCustomObject]$GroupingConfiguration
    }
}

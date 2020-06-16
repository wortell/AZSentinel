class IncidentConfiguration {
    [bool] $CreateIncident

    [GroupingConfiguration]$GroupingConfiguration

    IncidentConfiguration ($CreateIncident, $GroupingConfiguration) {
        $this.createIncident = if ($createIncident) { $createIncident } else { $true }
        $this.groupingConfiguration = $GroupingConfiguration
    }
}

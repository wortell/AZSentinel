class IncidentConfiguration {
    [bool] $CreateIncident = $true

    $GroupingConfiguration

    IncidentConfiguration ($CreateIncident, $GroupingConfiguration) {
        $this.createIncident = $CreateIncident
        $this.groupingConfiguration = $GroupingConfiguration
    }
}

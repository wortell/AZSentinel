class IncidentConfiguration {
    [bool] $CreateIncident

    [GroupingConfiguration]$GroupingConfiguration

    IncidentConfiguration ($CreateIncident, $GroupingConfiguration) {
        $this.createIncident = if ($null -ne $createIncident) { $createIncident } else { $true }
        $this.groupingConfiguration = $GroupingConfiguration
    }
}

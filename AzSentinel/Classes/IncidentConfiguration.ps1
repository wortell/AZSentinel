class IncidentConfiguration {
    [bool] $CreateIncident

    $GroupingConfiguration

    IncidentConfiguration ($CreateIncident, $GroupingConfiguration){
        $this.createIncident = $CreateIncident
        $this.groupingConfiguration = $GroupingConfiguration
    }
}

class groupingConfiguration {
    [bool]$Enabled

    [bool]$reopenClosedIncident

    [string]$lookbackDuration

    $entitiesMatchingMethod

    [GroupByEntities[]]$groupByEntities

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

    groupingConfiguration ($Enabled, $reopenClosedIncident, $lookbackDuration, $entitiesMatchingMethod, [GroupByEntities[]]$groupByEntities) {
        $this.enabled = $Enabled
        $this.reopenClosedIncident = $reopenClosedIncident
        $this.lookbackDuration = [groupingConfiguration]::TimeString($lookbackDuration)
        $this.entitiesMatchingMethod = $entitiesMatchingMethod
        $this.groupByEntities = $groupByEntities
    }

}

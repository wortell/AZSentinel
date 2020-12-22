class GroupingConfiguration {
    [bool]$enabled

    [bool]$reopenClosedIncident

    [string]$lookbackDuration

    [MatchingMethod]$entitiesMatchingMethod

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

    GroupingConfiguration ($properties) {
        $this.enabled = $properties.enabled
        $this.reopenClosedIncident = $properties.reopenClosedIncident
        $this.lookbackDuration = $properties.lookbackDuration
        $this.entitiesMatchingMethod = $properties.entitiesMatchingMethod
        $this.groupByEntities = $properties.groupByEntities
    }

    GroupingConfiguration ($enabled, $reopenClosedIncident, $lookbackDuration, $entitiesMatchingMethod, $groupByEntities) {
        $this.enabled = if ($null -ne $enabled ) { $enabled } else { $false }
        $this.reopenClosedIncident = if ($null -ne $reopenClosedIncident) { $reopenClosedIncident } else { $false }
        $this.lookbackDuration = if ($lookbackDuration) { [groupingConfiguration]::TimeString($lookbackDuration) } else { "PT5H" }
        $this.entitiesMatchingMethod = if ($entitiesMatchingMethod) { $entitiesMatchingMethod } else { "All" }
        $this.groupByEntities = if ($groupByEntities) { $groupByEntities } else {
            @(
                "Account",
                "Ip",
                "Host",
                "Url",
                "FileHash"
            )
        }
    }
}

class MicrosoftSecurityIncidentCreation {
    [string] $DisplayName
    [string]$Description
    [bool]$Enabled
    [string]$ProductFilter
    [Severity[]]$SeveritiesFilter
    [string]$DisplayNamesFilter

    MicrosoftSecurityIncidentCreation ($DisplayName, $Description, $Enabled, $ProductFilter, $SeveritiesFilter, $DisplayNamesFilter) {
        $this.displayName = $DisplayName
        $this.description = $Description
        $this.enabled = $Enabled
        $this.productFilter = $ProductFilter
        $this.severitiesFilter = $SeveritiesFilter
        $this.displayNamesFilter = $DisplayNamesFilter
    }
}

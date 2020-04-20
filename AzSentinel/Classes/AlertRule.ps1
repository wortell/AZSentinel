class AlertRule {
    [guid] $Name

    [string] $Etag

    [string]$type

    [ScheduledAlertProp, FusionAlertProp]$Properties

    [Parameter(Mandatory)]
    [string]$Id

    AlertRule ([guid]$Name, [string]$Etag, [ScheduledAlertProp, FusionAlertProp]$Properties, $Id) {

        $this.id = $Id
        $this.type = 'Microsoft.SecurityInsights/alertRules'
        $this.Name = $Name
        $this.Etag = $Etag
        $this.Properties = $Properties
    }
}

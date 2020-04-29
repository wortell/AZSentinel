class AlertRule {
    [guid] $Name

    [string] $Etag

    [string]$type

    [string]$kind

    [ScheduledAlertProp]$Properties

    [Parameter(Mandatory)]
    [string]$Id

    AlertRule ([guid]$Name, [string]$Etag, [ScheduledAlertProp]$Properties, $Id) {

        $this.id = $Id
        $this.type = 'Microsoft.SecurityInsights/alertRules'
        $this.kind = 'Scheduled'
        $this.Name = $Name
        $this.Etag = $Etag
        $this.Properties = $Properties
    }
}

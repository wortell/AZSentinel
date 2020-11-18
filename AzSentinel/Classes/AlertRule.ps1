class AlertRule {
    [string] $Name

    [string] $Etag

    [string]$type

    [Kind]$kind = 'Scheduled'

    [pscustomobject]$Properties

    [string]$Id

    AlertRule ($Name, $Etag, $Properties, $Id, $kind) {

        $this.id = $Id
        $this.type = 'Microsoft.SecurityInsights/alertRules'
        $this.kind = $kind
        $this.Name = $Name
        $this.Etag = $Etag
        $this.Properties = $Properties
    }
}

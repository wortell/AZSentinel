class AlertRule {
    [guid] $Name

    [string] $Etag

    [string]$type

    [string]$kind

    [pscustomobject]$Properties

    [string]$Id

    AlertRule ($Name, $Etag, $Properties, $Id) {

        $this.id = $Id
        $this.type = 'Microsoft.SecurityInsights/alertRules'
        $this.kind = 'Scheduled'
        $this.Name = $Name
        $this.Etag = $Etag
        $this.Properties = $Properties
    }
}

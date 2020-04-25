





class AlertRule {
    [guid] $Name

    [string] $Etag

    [string]$type

    [AlertProp]$Properties

    [Parameter(Mandatory)]
    [string]$Id

    AlertRule ([guid]$Name, [string]$Etag, [AlertProp]$Properties, $Id) {

        $this.id = $Id
        $this.type = 'Microsoft.SecurityInsights/alertRules'
        $this.Name = $Name
        $this.Etag = $Etag
        $this.Properties = $Properties
    }
}

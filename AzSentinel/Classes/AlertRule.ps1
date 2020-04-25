class AlertRule {
    [guid] $Name

    [string] $Kind

    [string] $Etag

    [string]$type

    $Properties

    [Parameter(Mandatory)]
    [string]$Id

    AlertRule ([guid]$Name, [string]$Kind, [string]$Etag, $Properties, $Id) {

        $this.id = $Id
        $this.type = 'Microsoft.SecurityInsights/alertRules'
        $this.Name = $Name
        $this.Kind = $Kind
        $this.Etag = $Etag
        $this.Properties = $Properties
    }
}

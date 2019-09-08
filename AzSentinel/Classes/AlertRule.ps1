class AlertProp {

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [guid] $Name

    [Parameter(Mandatory)]
    [string] $DisplayName

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $Description

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("Medium", "High", "Low", "Informational")]
    [string] $Severity

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [bool] $Enabled

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $Query

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $QueryFrequency

    [ValidateNotNullOrEmpty()]
    [string] $QueryPeriod

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("GreaterThan", "FewerThan", "EqualTo", "NotEqualTo")]
    [string] $TriggerOperator

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [Int] $TriggerThreshold

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [string] $SuppressionDuration

    [Parameter(Mandatory)]
    [bool] $SuppressionEnabled

    [Parameter(Mandatory)]
    [AllowEmptyCollection()]
    [array]$Tactics

    AlertProp ($Name, $DisplayName, $Description, $Severity, $Enabled, $Query, $QueryFrequency, $QueryPeriod, $TriggerOperator, $TriggerThreshold, $suppressionDuration, $suppressionEnabled, $Tactics) {
        $this.name = $Name
        $this.DisplayName = $DisplayName
        $this.Description = $Description
        $this.Severity = $Severity
        $this.Enabled = $Enabled
        $this.Query = $Query
        $this.QueryFrequency = ("PT" + $QueryFrequency).ToUpper()
        $this.QueryPeriod = ("PT" + $QueryPeriod).ToUpper()
        $this.TriggerOperator = $TriggerOperator
        $this.TriggerThreshold = $TriggerThreshold
        $this.SuppressionDuration = if (! ($null -eq $suppressionDuration) -or ! ($null -eq $suppressionEnabled)) { ("PT" + $suppressionDuration).ToUpper() } else { "PT1H" }
        $this.SuppressionEnabled = if ($suppressionEnabled) { $suppressionEnabled } else { $false }
        $this.Tactics = $Tactics
    }
}

class AlertRule {
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [guid] $Name

    [Parameter(Mandatory)]
    [string] $Etag

    [Parameter(Mandatory = $false)]
    [string]$type

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
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

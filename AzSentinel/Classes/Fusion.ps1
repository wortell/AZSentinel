class Fusion {
    [bool]$Enabled
    [string]$AlertRuleTemplateName

    Fusion ($Enabled, $AlertRuleTemplateName) {
        $this.enabled = $Enabled
        $this.AlertRuleTemplateName = $AlertRuleTemplateName
    }
}

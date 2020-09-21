class MLBehaviorAnalytics {
    [bool]$Enabled
    [string]$AlertRuleTemplateName

    MLBehaviorAnalytics ($Enabled, $AlertRuleTemplateName) {
        $this.enabled = $Enabled
        $this.AlertRuleTemplateName = $AlertRuleTemplateName
    }
}

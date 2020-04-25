class FusionAlertProp {

    [string] $AlertRuleTemplateName

    [bool] $Enabled

    FusionAlertProp ($AlertRuleTemplateName, $Enabled) {
        $this.AlertRuleTemplateName = $AlertRuleTemplateName
        $this.Enabled = $Enabled
    }
}

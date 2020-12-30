---
external help file: AzSentinel-help.xml
Module Name: AzSentinel
online version:
schema: 2.0.0
---

# Get-AzSentinelAlertRuleAction

## SYNOPSIS
Get Azure Sentinel Alert rule Action

## SYNTAX

```
Get-AzSentinelAlertRuleAction [-SubscriptionId <String>] -WorkspaceName <String> [-RuleName <String>]
 [-RuleId <String>] [<CommonParameters>]
```

## DESCRIPTION
This function can be used to see if an action is attached to the alert rule, if so then the configuration will be returned

## EXAMPLES

### EXAMPLE 1
```
Get-AzSentinelAlertRuleAction -WorkspaceName "" -RuleName "testrule01"
This example will get the Workspace ands return the full data object
```

## PARAMETERS

### -SubscriptionId
Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkspaceName
Enter the Workspace name

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RuleName
Enter the name of the Alert rule

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RuleId
Enter the Rule Id to skip Get-AzSentinelAlertRule step

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
NAME: Get-AzSentinelAlertRuleAction

## RELATED LINKS

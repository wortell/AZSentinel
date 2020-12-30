---
external help file: AzSentinel-help.xml
Module Name: AzSentinel
online version:
schema: 2.0.0
---

# New-AzSentinelAlertRuleAction

## SYNOPSIS
Create Azure Sentinal Alert Rule Action

## SYNTAX

```
New-AzSentinelAlertRuleAction [-SubscriptionId <String>] -WorkspaceName <String> -PlayBookName <String>
 [-RuleName <String>] [-RuleId <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Use this function to creates Azure Sentinal Alert rule action

## EXAMPLES

### EXAMPLE 1
```
New-AzSentinelAlertRuleAction -WorkspaceName "" -PlayBookName "Playbook01" -RuleName "AlertRule01"
New-AzSentinelAlertRuleAction -WorkspaceName "" -PlayBookName "Playbook01" -RuleId 'b6103d42-d2fb-4f35-xxx-c76a7f31ee4e'
In this example you you assign the playbook to the Alert rule
```

## PARAMETERS

### -SubscriptionId
Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used

```yaml
Type: String
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
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PlayBookName
Enter the Playbook name that you want to assign to the alert rule

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RuleName
Enter the Alert Rule name that you want to configure

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RuleId
Enter the Alert Rule ID that you want to configure

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

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

## RELATED LINKS

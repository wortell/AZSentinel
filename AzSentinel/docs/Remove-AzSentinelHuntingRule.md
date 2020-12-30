---
external help file: AzSentinel-help.xml
Module Name: AzSentinel
online version:
schema: 2.0.0
---

# Remove-AzSentinelHuntingRule

## SYNOPSIS
Remove Azure Sentinal Hunting Rules

## SYNTAX

```
Remove-AzSentinelHuntingRule [-SubscriptionId <String>] -WorkspaceName <String> [-RuleName <String[]>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
With this function you can remove Azure Sentinal hunting rules from Powershell, if you don't provide andy Hunting rule name all rules will be removed

## EXAMPLES

### EXAMPLE 1
```
Remove-AzSentinelHuntingRule -WorkspaceName "" -RuleName ""
In this example the defined hunting rule will be removed from Azure Sentinel
```

### EXAMPLE 2
```
Remove-AzSentinelHuntingRule -WorkspaceName "" -RuleName "","", ""
In this example you can define multiple hunting rules that will be removed
```

### EXAMPLE 3
```
Remove-AzSentinelHuntingRule -WorkspaceName ""
In this example no hunting rule is specified, all hunting rules will be removed one by one. For each rule you need to confirm the action
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
Enter the name of the rule that you wnat to remove

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: System.Management.Automation.SwitchParameter
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
Type: System.Management.Automation.SwitchParameter
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

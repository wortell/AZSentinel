---
external help file: AzSentinel-help.xml
Module Name: AzSentinel
online version:
schema: 2.0.0
---

# Get-AzSentinelAlertRule

## SYNOPSIS
Manage Azure Sentinal Alert Rules

## SYNTAX

```
Get-AzSentinelAlertRule [-SubscriptionId <String>] -WorkspaceName <String> [-RuleName <String[]>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
With this function you can get the configuration of the Azure Sentinel Alert rule from Azure Sentinel

## EXAMPLES

### EXAMPLE 1
```
Get-AzSentinelAlertRule -WorkspaceName "" -RuleName "",""
```

in this example all the rules configured in the JSON file will be created or updated

### EXAMPLE 2
```
Get-AzSentinelAlertRule -WorkspaceName "" -RuleName "" -SubscriptionId ""
```

in this example all the rules configured in the JSON file will be created or updated

### EXAMPLE 3
```
Get-AzSentinelAlertRule -WorkspaceName "" -subscriptionid ""
```

In this example you can select multiple JSON files and Pipeline it to the module

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

### -RuleName
Enter the name of the Alert rule

```yaml
Type: String[]
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

---
external help file: AzSentinel-help.xml
Module Name: AzSentinel
online version:
schema: 2.0.0
---

# Get-AzSentinelAlertRule

## SYNOPSIS
Get Azure Sentinel Alert Rules

## SYNTAX

```
Get-AzSentinelAlertRule [-SubscriptionId <String>] -WorkspaceName <String> [-RuleName <String[]>]
 [-Kind <Kind[]>] [-LastModified <DateTime>] [-SkipPlaybook] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
With this function you can get the configuration of the Azure Sentinel Alert rule from Azure Sentinel

## EXAMPLES

### EXAMPLE 1
```
Get-AzSentinelAlertRule -WorkspaceName "" -RuleName "",""
In this example you can get configuration of multiple alert rules in once
```

### EXAMPLE 2
```
Get-AzSentinelAlertRule -SubscriptionId "" -WorkspaceName "" -LastModified 2020-09-21
In this example you can get configuration of multiple alert rules only if modified after the 21st September 2020. The datetime must be in ISO8601 format.
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

### -Kind
The alert rule kind

```yaml
Type: Kind[]
Parameter Sets: (All)
Aliases:
Accepted values: Scheduled, Fusion, MLBehaviorAnalytics, MicrosoftSecurityIncidentCreation

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -LastModified
Filter for rules modified after this date/time

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -SkipPlaybook
Use SkipPlaybook switch to only return the rule properties, this skips the Playbook resolve step.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

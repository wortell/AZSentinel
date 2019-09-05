---
external help file: AzSentinel-help.xml
Module Name: AzSentinel
online version:
schema: 2.0.0
---

# New-AzAnalytic

## SYNOPSIS
Manage Azure Sentinal Alert Rules

## SYNTAX

```
New-AzAnalytic [-Subscription] <String> [-ResourceGroup] <String> [-Workspace] <String>
 [-SettingsFile] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function creates Azure Sentinal Alert rules from JSON and YAML config files.
This way you can manage your Alert rules dynamic from one JSON or multiple YAML files

## EXAMPLES

### EXAMPLE 1
```
New-AzAnalytic -Subscription "" -ResourceGroup "" -Workspace "" -SettingsFile ".\examples\AlertRules.json" -Verbose
```

Deploy example, this module support Json and Yaml format

## PARAMETERS

### -Subscription
Enter the subscription ID where the Workspace is deployed

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceGroup
Enter the resourceGroup name where the Workspace is deployed

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Workspace
Enter the Workspace name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SettingsFile
Path to the JSON or YAML file for the AlertRules

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
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

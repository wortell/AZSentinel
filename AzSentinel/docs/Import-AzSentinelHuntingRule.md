---
external help file: AzSentinel-help.xml
Module Name: AzSentinel
online version:
schema: 2.0.0
---

# Import-AzSentinelHuntingRule

## SYNOPSIS
Import Azure Sentinal Hunting rule

## SYNTAX

```
Import-AzSentinelHuntingRule [-SubscriptionId <String>] -WorkspaceName <String> -SettingsFile <FileInfo>
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function imports Azure Sentinal Hunnting rules from JSON and YAML config files.
This way you can manage your Hunting rules dynamic from JSON or multiple YAML files

## EXAMPLES

### EXAMPLE 1
```
Import-AzSentinelHuntingRule -WorkspaceName "infr-weu-oms-t-7qodryzoj6agu" -SettingsFile ".\examples\HuntingRules.json"
In this example all the rules configured in the JSON file will be created or updated
```

### EXAMPLE 2
```
Import-AzSentinelHuntingRule -WorkspaceName "" -SettingsFile ".\examples\HuntingRules.yaml"
In this example all the rules configured in the YAML file will be created or updated
```

### EXAMPLE 3
```
Get-Item .\examples\HuntingRules*.json | Import-AzSentinelHuntingRule -WorkspaceName ""
In this example you can select multiple JSON files and Pipeline it to the SettingsFile parameter
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

### -SettingsFile
Path to the JSON or YAML file for the Hunting rules

```yaml
Type: System.IO.FileInfo
Parameter Sets: (All)
Aliases:

Required: True
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

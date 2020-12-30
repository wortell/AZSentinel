---
external help file: AzSentinel-help.xml
Module Name: AzSentinel
online version:
schema: 2.0.0
---

# Import-AzSentinelDataConnector

## SYNOPSIS
Import Azure Sentinel Data Connectors

## SYNTAX

```
Import-AzSentinelDataConnector [-SubscriptionId <String>] -WorkspaceName <String> -SettingsFile <FileInfo>
 [<CommonParameters>]
```

## DESCRIPTION
This function imports Azure Sentinel Data Connectors

## EXAMPLES

### EXAMPLE 1
```
Import-AzSentinelDataConnector -WorkspaceName "" -SettingsFile ".\examples\DataConnectors.json"
In this example all the Data Conenctors configured in the JSON file will be created or updated
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

### -SettingsFile
Path to the JSON file for the Data Connectors

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

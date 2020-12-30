---
external help file: AzSentinel-help.xml
Module Name: AzSentinel
online version:
schema: 2.0.0
---

# Export-AzSentinel

## SYNOPSIS
Export Azure Sentinel

## SYNTAX

```
Export-AzSentinel [-SubscriptionId <String>] -WorkspaceName <String> -OutputFolder <FileInfo>
 -Kind <ExportType[]> [-TemplatesKind <Kind[]>] [<CommonParameters>]
```

## DESCRIPTION
With this function you can export Azure Sentinel configuration

## EXAMPLES

### EXAMPLE 1
```
Export-AzSentinel -WorkspaceName '' -Path C:\Temp\ -Kind All
In this example you export Alert, Hunting and Template rules
```

### EXAMPLE 2
```
Export-AzSentinel -WorkspaceName '' -Path C:\Temp\ -Kind Templates
In this example you export only the Templates
```

### EXAMPLE 3
```
Export-AzSentinel -WorkspaceName '' -Path C:\Temp\ -Kind Alert
In this example you export only the Scheduled Alert rules
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

### -OutputFolder
The Path where you want to export the JSON files

```yaml
Type: System.IO.FileInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Kind
Select what you want to export: Alert, Hunting, Templates or All

```yaml
Type: ExportType[]
Parameter Sets: (All)
Aliases:
Accepted values: Alert, Hunting, All, Templates

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -TemplatesKind
Select which Kind of templates you want to export, if empy all Templates will be exported

```yaml
Type: Kind[]
Parameter Sets: (All)
Aliases:
Accepted values: Scheduled, Fusion, MLBehaviorAnalytics, MicrosoftSecurityIncidentCreation

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

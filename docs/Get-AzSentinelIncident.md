---
external help file: AzSentinel-help.xml
Module Name: AzSentinel
online version:
schema: 2.0.0
---

# Get-AzSentinelIncident

## SYNOPSIS
Get Azure Sentinel Incident

## SYNTAX

```
Get-AzSentinelIncident [-SubscriptionId <String>] -WorkspaceName <String> [-IncidentName <String[]>]
 [-CaseNumber <Int32[]>] [-All] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
With this function you can get a list of open incidents from Azure Sentinel.
You can can also filter to Incident with speciefiek case namber or Case name

## EXAMPLES

### EXAMPLE 1
```
Get-AzSentinelIncident -WorkspaceName ""
Get a list of the last 200 Incidents
```

### EXAMPLE 2
```
Get-AzSentinelIncident -WorkspaceName "" -All
Get a list of all Incidents
```

### EXAMPLE 3
```
Get-AzSentinelIncident -WorkspaceName "" -CaseNumber
Get information of a specifiek incident with providing the casenumber
```

### EXAMPLE 4
```
Get-AzSentinelIncident -WorkspaceName "" -IncidentName "", ""
Get information of one or more incidents with providing a incident name, this is the name of the alert rule that triggered the incident
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

### -IncidentName
Enter incident name, this is the same name as the alert rule that triggered the incident

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

### -CaseNumber
Enter the case number to get specfiek details of a open case

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -All
Use -All switch to get a list of all the incidents

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

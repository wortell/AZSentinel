---
external help file: AzSentinel-help.xml
Module Name: AzSentinel
online version:
schema: 2.0.0
---

# Update-AzSentinelIncident

## SYNOPSIS
Update Azure Sentinel Incident

## SYNTAX

```
Update-AzSentinelIncident [-SubscriptionId <String>] -WorkspaceName <String> -CaseNumber <Int32>
 [-Severity <String>] [-Status <Status>] [-Comment <String>] [-Labels <String[]>] [-CloseReason <CloseReason>]
 [-ClosedReasonText <String>] [-Description <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
With this function you can update existing Azure Sentinel Incident.

## EXAMPLES

### EXAMPLE 1
```
Update-AzSentinelIncident -WorkspaceName ""
Get a list of all open Incidents
```

### EXAMPLE 2
```
Update-AzSentinelIncident -WorkspaceName '' -CaseNumber 42291 -Labels "NewLabel"
Add a new Label to list of Labels for a Incident
```

### EXAMPLE 3
```
Update-AzSentinelIncident -WorkspaceName '' -CaseNumber 42293 -Status Closed -CloseReason FalsePositive -ClosedReasonText "Your input"
Close the Incidnet using status Closed, when status closed is selected then CloseReason and ClosedReasonText prperty are required to be filled in
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

### -CaseNumber
Enter the case number to get specfiek details of a open case

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Severity
Enter the Severity, you can choose from Medium, High, Low and Informational

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

### -Status
Enter the Status of the incident, you can choose from New, InProgress and Closed

```yaml
Type: Status
Parameter Sets: (All)
Aliases:
Accepted values: New, InProgress, Closed

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Comment
Enter Comment tekst to add comment to the incident

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

### -Labels
Add Lebels to the incident, current configured Labels will be added to the existing Labels

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CloseReason
When Status is equil to Closed, CloseReason is required.
You can select from: TruePositive, FalsePositive

```yaml
Type: CloseReason
Parameter Sets: (All)
Aliases:
Accepted values: TruePositive, FalsePositive

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClosedReasonText
When Status is equil to Closed, ClosedReasonText is required to be filled in.

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

### -Description
{{ Fill Description Description }}

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

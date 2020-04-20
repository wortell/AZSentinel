---
external help file: AzSentinel-help.xml
Module Name: AzSentinel
online version:
schema: 2.0.0
---

# New-AzSentinelAlertRule

## SYNOPSIS
Create Azure Sentinal Alert Rules

## SYNTAX

```
New-AzSentinelAlertRule [-SubscriptionId <String>] -WorkspaceName <String> -DisplayName <String>
 -Description <String> -Severity <Severity> -Enabled <Boolean> -Query <String> -QueryFrequency <String>
 [-QueryPeriod <String>] -TriggerOperator <TriggerOperator> -TriggerThreshold <Int32>
 -SuppressionDuration <String> -SuppressionEnabled <Boolean> -Tactics <Tactics[]> [-PlaybookName <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Use this function creates Azure Sentinal Alert rules from provided CMDLET

## EXAMPLES

### EXAMPLE 1
```
New-AzSentinelAlertRule -WorkspaceName "" -DisplayName "" -Description "" -Severity -Enabled $true -Query '' -QueryFrequency "" -QueryPeriod "" -TriggerOperator -TriggerThreshold  -SuppressionDuration "" -SuppressionEnabled $false -Tactics @("","") -PlaybookName ""
In this example you create a new Alert rule by defining the rule properties from CMDLET
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

### -DisplayName
Enter the Display name for the Alert rule

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

### -Description
Enter the Description for the Alert rule

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

### -Severity
Enter the Severity, valid values: Medium", "High", "Low", "Informational"

```yaml
Type: Severity
Parameter Sets: (All)
Aliases:
Accepted values: Medium, High, Low, Informational

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Enabled
Set $true to enable the Alert Rule or $false to disable Alert Rule

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Query
Enter the Query that you want to use

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

### -QueryFrequency
Enter the query frequency, example: 5H, 5M, 5D (H stands for Hour, M stands for Minute and D stands for Day)

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

### -QueryPeriod
Enter the query period, exmaple: 5H, 5M, 5D (H stands for Hour, M stands for Minute and D stands for Day)

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

### -TriggerOperator
Select the triggert Operator, valid values are: "GreaterThan", "FewerThan", "EqualTo", "NotEqualTo"

```yaml
Type: TriggerOperator
Parameter Sets: (All)
Aliases:
Accepted values: GreaterThan, LessThan, Equal, NotEqual, gt, lt, eq, ne

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TriggerThreshold
Enter the trigger treshold

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -SuppressionDuration
Enter the suppression duration, example: 5H, 5M, 5D (H stands for Hour, M stands for Minute and D stands for Day)

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

### -SuppressionEnabled
Set $true to enable Suppression or $false to disable Suppression

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tactics
Enter the Tactics, valid values: "InitialAccess", "Persistence", "Execution", "PrivilegeEscalation", "DefenseEvasion", "CredentialAccess", "LateralMovement", "Discovery", "Collection", "Exfiltration", "CommandAndControl", "Impact"

```yaml
Type: Tactics[]
Parameter Sets: (All)
Aliases:
Accepted values: InitialAccess, Persistence, Execution, PrivilegeEscalation, DefenseEvasion, CredentialAccess, LateralMovement, Discovery, Collection, Exfiltration, CommandAndControl, Impact

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PlaybookName
Enter the Logic App name that you want to configure as playbook trigger

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

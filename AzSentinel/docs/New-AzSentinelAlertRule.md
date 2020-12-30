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
New-AzSentinelAlertRule [-SubscriptionId <String>] -WorkspaceName <String> [-Kind <Kind>]
 [-DisplayName <String>] [-Description <String>] [-Severity <Severity>] [-Enabled <Boolean>] [-Query <String>]
 [-QueryFrequency <String>] [-QueryPeriod <String>] [-TriggerOperator <TriggerOperator>]
 [-TriggerThreshold <Int32>] [-SuppressionDuration <String>] [-SuppressionEnabled <Boolean>]
 [-Tactics <String[]>] [-PlaybookName <String[]>] [-CreateIncident <Boolean>]
 [-GroupingConfigurationEnabled <Boolean>] [-ReopenClosedIncident <Boolean>] [-LookbackDuration <String>]
 [-EntitiesMatchingMethod <MatchingMethod>] [-GroupByEntities <String[]>] [-AggregationKind <AggregationKind>]
 [-AlertRuleTemplateName <String>] [-ProductFilter <String>] [-SeveritiesFilter <Severity[]>]
 [-DisplayNamesFilter <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Use this function creates Azure Sentinal Alert rules from provided CMDLET

## EXAMPLES

### EXAMPLE 1
```
New-AzSentinelAlertRule -WorkspaceName "" -DisplayName "" -Description "" -Severity -Enabled $true -Query '' -QueryFrequency "" -QueryPeriod "" -TriggerOperator -TriggerThreshold  -SuppressionDuration "" -SuppressionEnabled $false -Tactics @("","") -PlaybookName ""
Example on how to create a scheduled rule
```

### EXAMPLE 2
```
New-AzSentinelAlertRule -WorkspaceName "" -Kind Fusion -DisplayName "Advanced Multistage Attack Detection" -Enabled $true -AlertRuleTemplateName "f71aba3d-28fb-450b-b192-4e76a83015c8"
Example on how to create a Fusion rule
```

### EXAMPLE 3
```
New-AzSentinelAlertRule -WorkspaceName "" -Kind MLBehaviorAnalytics -DisplayName "(Preview) Anomalous SSH Login Detection" -Enabled $true -AlertRuleTemplateName "fa118b98-de46-4e94-87f9-8e6d5060b60b"
Example on how to create a MLBehaviorAnalytics rule
```

### EXAMPLE 4
```
New-AzSentinelAlertRule -WorkspaceName "" -Kind MicrosoftSecurityIncidentCreation -DisplayName "" -Description "" -Enabled $true -ProductFilter "" -SeveritiesFilter "","" -DisplayNamesFilter ""
Example on how to create a MicrosoftSecurityIncidentCreation rule
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

### -Kind
The alert rule kind

```yaml
Type: Kind
Parameter Sets: (All)
Aliases:
Accepted values: Scheduled, Fusion, MLBehaviorAnalytics, MicrosoftSecurityIncidentCreation

Required: False
Position: Named
Default value: Scheduled
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayName
The display name for alerts created by this alert rule.

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

### -Description
The description of the alert rule.

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

### -Severity
Enter the Severity, valid values: Medium", "High", "Low", "Informational"

```yaml
Type: Severity
Parameter Sets: (All)
Aliases:
Accepted values: Medium, High, Low, Informational

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Enabled
Determines whether this alert rule is enabled or disabled.

```yaml
Type: System.Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Query
The query that creates alerts for this rule.

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

### -QueryFrequency
Enter the query frequency, example: 5H, 5M, 5D (H stands for Hour, M stands for Minute and D stands for Day)

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

### -QueryPeriod
Enter the query period, exmaple: 5H, 5M, 5D (H stands for Hour, M stands for Minute and D stands for Day)

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

### -TriggerOperator
Select the triggert Operator, valid values are: "GreaterThan", "FewerThan", "EqualTo", "NotEqualTo"

```yaml
Type: TriggerOperator
Parameter Sets: (All)
Aliases:
Accepted values: GreaterThan, LessThan, Equal, NotEqual, gt, lt, eq, ne

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TriggerThreshold
Enter the trigger treshold

```yaml
Type: System.Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -SuppressionDuration
Enter the suppression duration, example: 5H, 5M, 5D (H stands for Hour, M stands for Minute and D stands for Day)

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

### -SuppressionEnabled
Set $true to enable Suppression or $false to disable Suppression

```yaml
Type: System.Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tactics
Enter the Tactics, valid values: "InitialAccess", "Persistence", "Execution", "PrivilegeEscalation", "DefenseEvasion", "CredentialAccess", "LateralMovement", "Discovery", "Collection", "Exfiltration", "CommandAndControl", "Impact"

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PlaybookName
Enter the Logic App name that you want to configure as playbook trigger

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CreateIncident
Create incidents from alerts triggered by this analytics rule

```yaml
Type: System.Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupingConfigurationEnabled
Group related alerts, triggered by this analytics rule, into incidents

```yaml
Type: System.Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReopenClosedIncident
Re-open closed matching incidents

```yaml
Type: System.Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -LookbackDuration
Limit the group to alerts created within the selected time frame

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

### -EntitiesMatchingMethod
Group alerts triggered by this analytics rule into a single incident by

```yaml
Type: MatchingMethod
Parameter Sets: (All)
Aliases:
Accepted values: All, None, Custom

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupByEntities
Grouping alerts into a single incident if the selected entities match:

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AggregationKind
Configure how rule query results are grouped into alerts

```yaml
Type: AggregationKind
Parameter Sets: (All)
Aliases:
Accepted values: SingleAlert, AlertPerResult

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AlertRuleTemplateName
The Name of the alert rule template used to create this rule

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

### -ProductFilter
The alerts' productName on which the cases will be generated

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

### -SeveritiesFilter
The alerts' severities on which the cases will be generated

```yaml
Type: Severity[]
Parameter Sets: (All)
Aliases:
Accepted values: Medium, High, Low, Informational

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayNamesFilter
The alerts' displayNames on which the cases will be generated

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

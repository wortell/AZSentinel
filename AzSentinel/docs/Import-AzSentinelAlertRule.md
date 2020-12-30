---
external help file: AzSentinel-help.xml
Module Name: AzSentinel
online version:
schema: 2.0.0
---

# Import-AzSentinelAlertRule

## SYNOPSIS
Import Azure Sentinal Alert rule

## SYNTAX

```
Import-AzSentinelAlertRule [-SubscriptionId <String>] -WorkspaceName <String> -SettingsFile <FileInfo>
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function imports Azure Sentinal Alert rules from JSON and YAML config files.
This way you can manage your Alert rules dynamic from JSON or multiple YAML files

## EXAMPLES

### EXAMPLE 1
```
Import-AzSentinelAlertRule -WorkspaceName "" -SettingsFile ".\examples\AlertRules.json"
In this example all the rules configured in the JSON file will be created or updated
```

Performing the operation "Import-AzSentinelAlertRule" on target "Do you want to update profile: AlertRule01".
\[Y\] Yes \[A\] Yes to All \[N\] No \[L\] No to All \[S\] Suspend \[?\] Help (default is "Yes"):
Successfully created Action for Rule:  with Playbook pkmsentinel Status: Created
Created
Successfully updated rule: AlertRule01 with status: OK

Name                : b6103d42-xxx-4f35-xxx-c76a7f31ee4e
DisplayName         : AlertRule01
Description         :
Severity            : Medium
Enabled             : True
Query               : SecurityEvent | where EventID == "4688" | where CommandLine contains "-noni -ep bypass $"
QueryFrequency      : PT5H
QueryPeriod         : PT6H
TriggerOperator     : GreaterThan
TriggerThreshold    : 5
SuppressionDuration : PT6H
SuppressionEnabled  : False
Tactics             : {Persistence, LateralMovement, Collection}
PlaybookName        : Playbook01

### EXAMPLE 2
```
Import-AzSentinelAlertRule -WorkspaceName "" -SettingsFile ".\examples\SuspectApplicationConsent.yaml"
In this example all the rules configured in the YAML file will be created or updated
```

### EXAMPLE 3
```
Get-Item .\examples\*.json | Import-AzSentinelAlertRule -WorkspaceName ""
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
Path to the JSON or YAML file for the AlertRules

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

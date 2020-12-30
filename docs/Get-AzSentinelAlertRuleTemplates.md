---
external help file: AzSentinel-help.xml
Module Name: AzSentinel
online version:
schema: 2.0.0
---

# Get-AzSentinelAlertRuleTemplates

## SYNOPSIS
Get Azure Sentinel Alert Rules Templates

## SYNTAX

```
Get-AzSentinelAlertRuleTemplates [-SubscriptionId <String>] -WorkspaceName <String> [-Kind <Kind[]>]
 [<CommonParameters>]
```

## DESCRIPTION
With this function you can get the configuration of the Azure Sentinel Alert Rules Templates from Azure Sentinel

## EXAMPLES

### EXAMPLE 1
```
Get-AzSentinelAlertRuleTemplates -WorkspaceName ""
In this example you can get Sentinel alert rules templates in once
```

### EXAMPLE 2
```
Get-AzSentinelAlertRuleTemplates -WorkspaceName "" -Kind Fusion, MicrosoftSecurityIncidentCreation
Filter on the Kind
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

### -Kind
Enter the Kind to filter on the templates

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

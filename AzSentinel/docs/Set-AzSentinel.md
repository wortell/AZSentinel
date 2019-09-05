---
external help file: AzSentinel-help.xml
Module Name: AzSentinel
online version:
schema: 2.0.0
---

# Set-AzSentinel

## SYNOPSIS
Enable Azure Sentinel

## SYNTAX

```
Set-AzSentinel [-Subscription] <String> [-ResourceGroup] <String> [-Workspace] <String> [[-Test] <Boolean>]
 [<CommonParameters>]
```

## DESCRIPTION
This function enables Azure Sentinel trough Rest API Call

## EXAMPLES

### EXAMPLE 1
```
Set-AzSentinel -Subscription "" -ResourceGroup "" -Workspace ""
```

Run in production mode, changes will be applied

### EXAMPLE 2
```
Set-AzSentinel -Subscription "" -ResourceGroup "" -Workspace "" -Test $true -Verbose
```

Run in Test mode and verbose mode, no changes will be applied

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

### -Test
Set $true if you want to run in tests mode without pushing any change

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

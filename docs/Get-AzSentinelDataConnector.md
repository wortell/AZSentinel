---
external help file: AzSentinel-help.xml
Module Name: AzSentinel
online version:
schema: 2.0.0
---

# Get-AzSentinelDataConnector

## SYNOPSIS
Get Azure Sentinel Data connector

## SYNTAX

```
Get-AzSentinelDataConnector [-SubscriptionId <String>] -WorkspaceName <String> [-DataConnectorName <String[]>]
 [-DataSourceName <DataSourceName[]>] [<CommonParameters>]
```

## DESCRIPTION
With this function you can get Azure Sentinel data connectors that are enabled on the workspace

## EXAMPLES

### EXAMPLE 1
```
Get-AzSentinelDataConnector -WorkspaceName ""
List all  enabled dataconnector
```

### EXAMPLE 2
```
Get-AzSentinelDataConnector -WorkspaceName "" -DataConnectorName "",""
Get specific dataconnectors
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

### -DataConnectorName
Enter the Connector ID

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

### -DataSourceName
{{ Fill DataSourceName Description }}

```yaml
Type: DataSourceName[]
Parameter Sets: (All)
Aliases:
Accepted values: ApplicationInsights, AzureActivityLog, AzureAuditLog, ChangeTrackingContentLocation, ChangeTrackingCustomPath, ChangeTrackingDataTypeConfiguration, ChangeTrackingDefaultRegistry, ChangeTrackingLinuxPath, ChangeTrackingPath, ChangeTrackingRegistry, ChangeTrackingServices, CustomLog, CustomLogCollection, DnsAnalytics, GenericDataSource, IISLogs, ImportComputerGroup, Itsm, LinuxChangeTrackingPath, LinuxPerformanceCollection, LinuxPerformanceObject, LinuxSyslog, LinuxSyslogCollection, NetworkMonitoring, Office365, SecurityCenterSecurityWindowsBaselineConfiguration, SecurityEventCollectionConfiguration, SecurityInsightsSecurityEventCollectionConfiguration, SecurityWindowsBaselineConfiguration, SqlDataClassification, WindowsEvent, WindowsPerformanceCounter, WindowsTelemetry

Required: False
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

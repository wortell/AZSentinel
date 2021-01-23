# Azure Sentinel

| branch      | status                                                                                         |
| ----------- | ---------------------------------------------------------------------------------------------- |
| master      | ![](https://github.com/wortell/AZSentinel/workflows/Build-Module/badge.svg?branch=master)      |
| development | ![](https://github.com/wortell/AZSentinel/workflows/Build-Module/badge.svg?branch=development) |

Azure Sentinel is a cloud-native SIEM that provides intelligent security analytics for your entire enterprise at cloud scale. Get limitless cloud speed and scale to help focus on what really matters. Easily collect data from all your cloud or on-premises assets, Office 365, Azure resources, and other clouds. Effectively detect threats with built-in machine learning from Microsoft’s security analytics experts. Automate threat response, using built-in orchestration and automation playbooks. [read more](https://docs.microsoft.com/en-us/azure/sentinel/overview)

## Why this PowerShell Module

At the moment there is no documented API, ARM or PowerShell module to configure Azure Sentinel. After doing some research we were able to find the API's that are currently being used by the Azure Portal and based on that we've written a PowerShell module to manage Azure Sentinel through PowerShell.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

* [PowerShell Core](https://github.com/PowerShell/PowerShell)
* Powershell [AZ Module](https://www.powershellgallery.com/packages/Az) - tested with version 2.4.0
* PowerShell [powershell-yaml Module](https://www.powershellgallery.com/packages/powershell-yaml) - tested with version 0.4.0

### Installing

You can install the latest version of AzSentinel module from [PowerShell Gallery](https://www.powershellgallery.com/packages/AzSentinel)

```PowerShell
Install-Module AzSentinel -Scope CurrentUser -Force
```

### Usage

#### Parameters

See [docs](https://github.com/wortell/AzSentinel/tree/master/docs) folder for documentation regarding the Functions and the available parameters

## JSON format

To create a Azure Sentinel Rule, use the following JSON format.

### Root schema
```JSON
{
  "Scheduled": [
    ...
  ],
  "Fusion": [
    ...
  ],
  "MLBehaviorAnalytics": [
    ...
  ],
  "MicrosoftSecurityIncidentCreation": [
    ...
  ]
}
```

### Scheduled rule

```JSON
  {
    "displayName": "string",
    "description": "string",
    "AlertRuleTemplateName": "string",
    "severity": "High",
    "enabled": true,
    "query": "SecurityEvent | where EventID == \"4688\" | where CommandLine contains \"-noni -ep bypass $\"",
    "queryFrequency": "5H",
    "queryPeriod": "5H",
    "triggerOperator": "GreaterThan",
    "triggerThreshold": 5,
    "suppressionDuration": "6H",
    "suppressionEnabled": false,
    "tactics": [
      "Persistence",
      "LateralMovement",
      "Collection"
    ],
    "playbookName": "string",
    "aggregationKind": "string",
    "incidentConfiguration": {
      "createIncident": true,
      "groupingConfiguration": {
        "GroupingConfigurationEnabled": true,
        "reopenClosedIncident": true,
        "lookbackDuration": "PT6H",
        "entitiesMatchingMethod": "string",
        "groupByEntities": [
          "Account",
          "Ip",
          "Host",
          "Url",
          "FileHash"
        ]
      }
    }
  }
```

#### Scheduled property values

The following tables describe the values you need to set in the schema.

| Name                         | Type   | Required | Allowed Values                                                                                                                                                      | Example                                                                                                                    |
| ---------------------------- | ------ | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| displayName                  | string | true     | *                                                                                                                                                                   | DisplayName                                                                                                                |
| description                  | string | true     | *                                                                                                                                                                   | Description                                                                                                                |
| severity                     | string | true     | Medium, High, Low, Informational                                                                                                                                    | Medium                                                                                                                     |
| enabled                      | bool   | true     | true, false                                                                                                                                                         | true                                                                                                                       |
| query                        | string | true     | special character need to be escaped by \                                                                                                                           | SecurityEvent \| where EventID == \"4688\" \| where CommandLine contains \\"-noni -ep bypass $\\"                          |
| queryFrequency               | string | true     | Value must be between 5 minutes and 24 hours                                                                                                                        | 30M                                                                                                                        |
| queryPeriod                  | string | true     | Value must be between 5 minutes and 14 days                                                                                                                         | 6H                                                                                                                         |
| triggerOperator              | string | true     | GreaterThan, FewerThan, EqualTo, NotEqualTo                                                                                                                         | GreaterThan                                                                                                                |
| triggerThreshold             | int    | true     | The value must be between 0 and 10000                                                                                                                               | 5                                                                                                                          |
| suppressionDuration          | string | true     | Value must be greater than 5 minutes                                                                                                                                | 1D                                                                                                                         |
| suppressionEnabled           | bool   | true     | true, false                                                                                                                                                         | true                                                                                                                       |
| tactics                      | array  | true     | InitialAccess, Persistence,Execution,PrivilegeEscalation,DefenseEvasion,CredentialAccess,LateralMovement,Discovery,Collection,Exfiltration,CommandAndControl,Impact | true                                                                                                                       |
| playbookName                 | string | false    | Enter the Logic App name or Resource ID                                                                                                                             | LogicApp01 / /subscriptions/SUBSCRIPTIONID/resourceGroups/RESOURCEGROUPNAME/providers/Microsoft.Logic/workflows/playbook02 |
| aggregationKind              | string | false    | SingleAlert, AlertPerRow                                                                                                                                            | SingleAlert                                                                                                                |
| createIncident               | bool   | false    | true, false                                                                                                                                                         | true                                                                                                                       |
| GroupingConfigurationEnabled | bool   | false    | true, false                                                                                                                                                         | true                                                                                                                       |
| reopenClosedIncident         | bool   | false    | true, false                                                                                                                                                         | true                                                                                                                       |
| lookbackDuration             | string | false    | Value must be between 5 minutes and 24 hours.                                                                                                                       | PT6H                                                                                                                       |
| entitiesMatchingMethod       | string | false    | All, None, Custom                                                                                                                                                   | All                                                                                                                        |
| groupByEntities              | string | false    | Account, Ip, Host, Url, FileHash                                                                                                                                | Account                                                                                                                    |
| AlertRuleTemplateName | string | false | Name of the alert rule template | 826bb2f8-7894-4785-9a6b-a8a855d8366f |

### Fusion rule
```JSON
  {
    "displayName": "Advanced Multistage Attack Detection",
    "enabled": true,
    "alertRuleTemplateName": "f71aba3d-28fb-450b-b192-4e76a83015c8"
  }
```

#### Scheduled property values

The following tables describe the values you need to set in the schema.

| Name                  | Type   | Required | Allowed Values | Example                              |
| --------------------- | ------ | -------- | -------------- | ------------------------------------ |
| displayName           | string | true     |                | Advanced Multistage Attack Detection |
| enabled               | bool   | true     |                | true                                 |
| alertRuleTemplateName | string | true     |                | f71aba3d-28fb-450b-b192-4e76a83015c8 |
|                       |        |          |                |



### MLBehaviorAnalytics rules

```JSON
  {
    "displayName": "(Preview) Anomalous SSH Login Detection",
    "enabled": true,
    "alertRuleTemplateName": "fa118b98-de46-4e94-87f9-8e6d5060b60b"
  }
```

#### Scheduled property values

The following tables describe the values you need to set in the schema.

| Name                  | Type   | Required | Allowed Values | Example                              |
| --------------------- | ------ | -------- | -------------- | ------------------------------------ |
| displayName           | string | true     |                | Advanced Multistage Attack Detection |
| enabled               | bool   | true     |                | true                                 |
| alertRuleTemplateName | string | true     |                | f71aba3d-28fb-450b-b192-4e76a83015c8 |
|                       |        |          |                |


### MicrosoftSecurityIncidentCreation rules
```JSON
  {
    "displayName": "Create incidents based on Azure Active Directory Identity Protection alerts",
    "description": "Create incidents based on all alerts generated in Azure Active Directory Identity Protection",
    "enabled": true,
    "productFilter": "Microsoft Cloud App Security",
    "severitiesFilter": [
      "High",
      "Medium",
      "Low"
    ],
    "displayNamesFilter": null
  }
```
#### Scheduled property values

The following tables describe the values you need to set in the schema.

| Name               | Type   | Required | Allowed Values    | Example                                                                                      |
| ------------------ | ------ | -------- | ----------------- | -------------------------------------------------------------------------------------------- |
| displayName        | string | true     |                   | Create incidents based on Azure Active Directory Identity Protection alerts                  |
| enabled            | bool   | true     |                   | true                                                                                         |
| description        | string | true     |                   | Create incidents based on all alerts generated in Azure Active Directory Identity Protection |
| productFilter      | string | true     |                   | Microsoft Cloud App Security                                                                 |
| severitiesFilter   | string | true     | High, Medium, Low | High                                                                                         |
| displayNamesFilter | string | false    |                   |                                                                                              |
|                    |        |          |                   |                                                                                              |


## Find us

* [GitHub](https://github.com/wortell/AZSentinel)
* [PowerShell Gallery](https://www.powershellgallery.com/packages/AzSentinel)

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Contributors

* A big thank you goes out to all the [contributors](https://github.com/wortell/AzSentinel/contributors) for their contributions!

## Authors

* **Pouyan Khabazi** - *Developer and Maintainer* - [GitHub](https://github.com/pkhabazi) / [Blog](https://pkm-technology.com)

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/wortell/AzSentinel/tags).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* Hat tip to anyone whose code was used!

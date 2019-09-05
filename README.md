# Azure Sentinel

Azure Sentinel Preview is a cloud-native SIEM that provides intelligent security analytics for your entire enterprise at cloud scale. Get limitless cloud speed and scale to help focus on what really matters. Easily collect data from all your cloud or on-premises assets, Office 365, Azure resources, and other clouds. Effectively detect threats with built-in machine learning from Microsoft’s security analytics experts. Automate threat response, using built-in orchestration and automation playbooks. [read more](https://docs.microsoft.com/en-us/azure/sentinel/overview)

## Manageability

At the moment there is no documented API, ARM or PowerShell code to configure Azure Sentinel

## Why this PowerShell Module

Well at the moment there is simply no PS module or well documented API reference fore creating managing Azure Sentinel. After doing some reverse engineering I was able to find the API's that are currently being used by the Azure Portal and based on that I have written a PowerShell module so that we can manage Azure Sentinel trough PowerShell.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisities

* Powershell [AZ Module](https://www.powershellgallery.com/packages/Az) - tested with version 2.4.0

### Installing

A step by step Guid how to install module

```PowerShell
Install-Module .\AzSentinel -Force
```

### Usage

#### Parameters

See [docs](https://github.com/pkhabazi/AzSentinel/tree/master/docs) folder for documentation regarding the Functions and the available parameters

## JSON format

To create a Azure Sentinel Rule, use the following JSON format.

```JSON
{
    "analytics": [
        {
            "displayName": "string",
            "description": "string",
            "severity": "High",
            "enabled": true,
            "query": "SecurityEvent | where EventID == \"4688\" | where CommandLine contains \"-noni -ep bypass $\"",
            "queryFrequency": "5H",
            "queryPeriod": "5H",
            "triggerOperator": "GreaterThan",
            "triggerThreshold": 5,
            "suppressionDuration": "6H",
            "suppressionEnabled": false,
        }
    ]
}
```

### Property values

The following tables describe the values you need to set in the schema.

| Name                | Type   | Required | Allowed Values                               | Example                                                                                           |
| ------------------- | ------ | -------- | -------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| displayName         | string | yes      | *                                            | DisplayName                                                                                       |
| description         | string | yes      | *                                            | Description                                                                                       |
| severity            | string | yes      | Medium, High, Low, Informational             | Medium                                                                                            |
| enabled             | bool   | yes      | true, false                                  | true                                                                                              |
| query               | string | yes      | special character need to be escaped by \    | SecurityEvent \| where EventID == \"4688\" \| where CommandLine contains \\"-noni -ep bypass $\\" |
| queryFrequency      | string | yes      | Value must be between 5 minutes and 24 hours | 5H                                                                                                |
| queryPeriod         | string | yes      | Value must be between 5 minutes and 24 hours | 1440M                                                                                             |
| triggerOperator     | string | yes      | GreaterThan, FewerThan, EqualTo, NotEqualTo  | GreaterThan                                                                                       |
| triggerThreshold    | int    | yes      | The value must be between 0 and 10000        | 5                                                                                                 |
| suppressionDuration | string | yes      | Value must be between 5 minutes and 24 hours | 11H                                                                                               |
| suppressionEnabled  | bool   | yes      | true, false                                  | true                                                                                              |

## Find us

* [Wortell](https://security.wortell.nl/)
* [GitHub](https://github.com/wortell/AZSentinel)

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/wortell/AzSentinel/tags).

## Authors

* **Pouyan Khabazi** - *Initial work* - [GitHub](https://github.com/pkhabazi) / [Blog](https://pkm-technology.com)

See also the list of [contributors](https://github.com/wortell/AzSentinel/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* Hat tip to anyone whose code was used

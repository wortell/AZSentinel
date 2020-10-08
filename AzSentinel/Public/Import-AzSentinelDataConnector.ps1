#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Import-AzSentinelDataConnector {
    <#
    .SYNOPSIS
    Import Azure Sentinel Data Connectors
    .DESCRIPTION
    This function imports Azure Sentinel Data Connectors
    .PARAMETER SubscriptionId
    Enter the subscription ID, if no subscription ID is provided then current AZContext subscription will be used
    .PARAMETER WorkspaceName
    Enter the Workspace name
    .PARAMETER SettingsFile
    Path to the JSON file for the Data Connectors
    .EXAMPLE
    Import-AzSentinelDataConnector -WorkspaceName "" -SettingsFile ".\examples\DataConnectors.json"
    In this example all the Data Conenctors configured in the JSON file will be created or updated
    #>

    param (
        [Parameter(Mandatory = $false,
            ParameterSetName = "Sub")]
        [ValidateNotNullOrEmpty()]
        [string] $SubscriptionId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $WorkspaceName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript( { (Test-Path -Path $_) -and ($_.Extension -in '.json') })]
        [System.IO.FileInfo] $SettingsFile
    )

    begin {
        precheck
    }

    process {
        switch ($PsCmdlet.ParameterSetName) {
            Sub {
                $arguments = @{
                    WorkspaceName  = $WorkspaceName
                    SubscriptionId = $SubscriptionId
                }
            }
            default {
                $arguments = @{
                    WorkspaceName  = $WorkspaceName
                    SubscriptionId = $script:SubscriptionId
                }
            }
        }
        Get-LogAnalyticWorkspace @arguments

        if ($SettingsFile.Extension -eq '.json') {
            try {
                $connectors = Get-Content -Raw $SettingsFile | ConvertFrom-Json -Depth 99
            }
            catch {
                Write-Verbose $_
                Write-Error -Message 'Unable to import JSON file' -ErrorAction Stop
            }
        }
        else {
            Write-Error -Message 'Unsupported extension for SettingsFile' -ErrorAction Stop
        }

        <#
            Get all the DataConenctors
        #>
        $enabledDataConnectors = Get-AzSentinelDataConnector @arguments -ErrorAction SilentlyContinue

        <#
            Get AzureActivityLog connector data
        #>
        $azureActivityLog = Get-AzSentinelDataConnector @arguments -DataSourceName 'AzureActivityLog' -ErrorAction SilentlyContinue

        foreach ($item in $connectors.AzureActivityLog) {
            $azureActivity = $azureActivityLog | Where-Object { $_.properties.linkedResourceId.Split('/')[2] -eq $item.subscriptionId }

            if ($azureActivity) {
                Write-Host "AzureActivityLog is already enabled on '$($item.subscriptionId)'"
            }
            else {
                $name = ($item.subscriptionId).Replace('-', '')
                $connectorBody = @{
                    id         = "$script:Workspace/datasources/$name"
                    name       = $name
                    type       = 'Microsoft.OperationalInsights/workspaces/datasources'
                    kind       = 'AzureActivityLog'
                    properties = @{
                        linkedResourceId = "/subscriptions/$($item.subscriptionId)/providers/microsoft.insights/eventtypes/management"
                    }
                }

                $uri = "$baseUri/datasources/$($name)?api-version=2020-03-01-preview"

                try {
                    $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($connectorBody | ConvertTo-Json -Depth 4 -EnumsAsStrings)

                    Write-Host "Successfully enabled AzureActivityLog for: $($item.subscriptionId) with status: $($result.StatusDescription)"
                }
                catch {
                    $errorReturn = $_.Exception.Message
                    Write-Verbose $_
                    Write-Error "Unable to invoke webrequest with error message: $($errorReturn)" -ErrorAction Stop
                }
            }
        }

        #AzureSecurityCenter connector
        foreach ($item in $connectors.AzureSecurityCenter) {

            $azureSecurityCenter = $enabledDataConnectors | Where-Object { $_.Kind -eq "AzureSecurityCenter" -and $_.properties.subscriptionId -eq $item.subscriptionId }
            $skip = $false

            if ($null -ne $azureSecurityCenter) {
                if ($azureSecurityCenter.properties.dataTypes.alerts.state -eq $item.state) {
                    Write-Host "AzureSecurityCenter is already '$($item.state)' for subscription '$($azureSecurityCenter.properties.subscriptionId)'"
                    $skip = $true
                }
                else {
                    $connectorBody = @{
                        id         = $azureSecurityCenter.id
                        name       = $azureSecurityCenter.name
                        etag       = $azureSecurityCenter.etag
                        type       = 'Microsoft.SecurityInsights/dataConnectors'
                        kind       = 'AzureSecurityCenter'
                        properties = @{
                            subscriptionId = $azureSecurityCenter.properties.subscriptionId
                            dataTypes      = @{
                                alerts = @{
                                    state = $item.state
                                }
                            }
                        }
                    }
                }
            }
            else {
                $guid = (New-Guid).Guid

                $connectorBody = @{
                    id         = "$script:Workspace/providers/Microsoft.SecurityInsights/dataConnectors/$guid"
                    name       = $guid
                    type       = 'Microsoft.SecurityInsights/dataConnectors'
                    kind       = 'AzureSecurityCenter'
                    properties = @{
                        subscriptionId = $item.subscriptionId
                        dataTypes      = @{
                            alerts = @{
                                state = $item.state
                            }
                        }
                    }
                }
            }

            if ($skip -eq $false) {
                # Enable or update AzureSecurityCenter with http put method
                $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/dataConnectors/$($connectorBody.name)?api-version=2020-01-01"

                try {
                    $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($connectorBody | ConvertTo-Json -Depth 4 -EnumsAsStrings)

                    Write-Host "Successfully enabled AzureSecurityCenter for: $($item.subscriptionId) with status: $($result.StatusDescription)"

                }
                catch {
                    $errorReturn = $_
                    $errorResult = ($errorReturn | ConvertFrom-Json ).error
                    Write-Verbose $_
                    Write-Error "Unable to invoke webrequest with error message: $($errorResult.message)" -ErrorAction Stop
                }
            }
        }

        #ThreatIntelligenceTaxii
        foreach ($item in $connectors.ThreatIntelligenceTaxii) {
            $threatIntelligenceTaxii = $enabledDataConnectors | Where-Object { $_.Kind -eq "ThreatIntelligenceTaxii" -and $_.properties.friendlyName -eq $item.friendlyName }
            $skip = $false

            if ($null -ne $threatIntelligenceTaxii) {

                if ($threatIntelligenceTaxii.properties.dataTypes.taxiiClient.state -eq $item.state) {
                    Write-Host "ThreatIntelligenceTaxii is already $($item.state) for '$($item.friendlyName)'"
                    $skip = $true
                }
                else {
                    # Compose body for connector update scenario
                    $connectorBody = @{
                        id         = $threatIntelligenceTaxii.id
                        name       = $threatIntelligenceTaxii.name
                        etag       = $threatIntelligenceTaxii.etag
                        type       = 'Microsoft.SecurityInsights/dataConnectors'
                        kind       = 'ThreatIntelligenceTaxii'
                        properties = @{
                            tenantId     = $script:tenantId
                            workspaceId  = $script:workspaceId
                            friendlyName = $item.friendlyName
                            taxiiServer  = $item.taxiiServer
                            collectionId = $item.collectionId
                            username     = $item.username
                            password     = $item.password
                            taxiiClients = $null
                            dataTypes    = @{
                                taxiiClient = @{
                                    state = $item.state
                                }
                            }
                        }
                    }
                }
            }
            else {
                $guid = (New-Guid).Guid
                # Compose body for connector enable scenario
                $connectorBody = @{
                    id         = "$script:Workspace/providers/Microsoft.SecurityInsights/dataConnectors/$guid"
                    name       = $guid
                    type       = 'Microsoft.SecurityInsights/dataConnectors'
                    kind       = 'ThreatIntelligenceTaxii'
                    properties = @{
                        tenantId     = $script:tenantId
                        workspaceId  = $script:workspaceId
                        friendlyName = $item.friendlyName
                        taxiiServer  = $item.taxiiServer
                        collectionId = $item.collectionId
                        username     = $item.username
                        password     = $item.password
                        taxiiClients = $null
                        dataTypes    = @{
                            taxiiClient = @{
                                state = $item.state
                            }
                        }
                    }
                }
            }

            if ($skip -eq $false) {
                # Enable or update ThreatIntelligenceTaxii
                $uri = "$script:baseUri/providers/Microsoft.SecurityInsights/dataConnectors/$($connectorBody.name)?api-version=2020-01-01"

                try {
                    $result = Invoke-webrequest -Uri $uri -Method Put -Headers $script:authHeader -Body ($connectorBody | ConvertTo-Json -Depth 4 -EnumsAsStrings)

                    Write-Host "Successfully enabled ThreatIntelligenceTaxii for: $($item.friendlyName) with status: $($result.StatusDescription)"
                }
                catch {
                    $errorReturn = $_.Exception.Message
                    Write-Verbose $_
                    Write-Error "Unable to invoke webrequest with error message: $($errorReturn)" -ErrorAction Stop
                }
            }
        }
    }
}

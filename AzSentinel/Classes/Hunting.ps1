class Hunting {
    [string]$DisplayName
    [string]$Query

    [string]$Description
    [Tactics[]]$Tactics

    [string]$Category
    [pscustomobject]$Tags

    Hunting($DisplayName, $Query, $Description, $Tactics) {
        $this.Category = 'Hunting Queries'
        $this.DisplayName = $DisplayName
        $this.Query = $Query
        $this.Tags = @(
            @{
                'Name'  = "description"
                'Value' = $Description
            },
            @{
                "Name"  = "tactics"
                "Value" = $Tactics -join ','
            },
            @{
                "Name"  = "createdBy"
                "Value" = ""
            },
            @{
                "Name"  = "createdTimeUtc"
                "Value" = ""
            }
        )

    }
}

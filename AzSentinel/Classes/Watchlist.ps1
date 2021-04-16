class Watchlist {

    [string]$DisplayName
    [string]$Description
    [string]$rawContent
    [int]$numberOfLinesToSkip

    $properties

    watchList ($DisplayName, $rawContent, $Description, $numberOfLinesToSkip) {
        $this.properties = @{
            contentType = "text/csv"
            description = $Description
            displayName = $DisplayName
            numberOfLinesToSkip = if ($numberOfLinesToSkip) { $numberOfLinesToSkip } else { 0 }
            provider = "Microsoft"
            rawContent = $rawContent
            "source" = "Local file"
        }
    }
}


$body = [Watchlist]::new(
    "displaynaam",
    "tes1,test2",
    "description",
    ""
)

$body.properties

class HuntingRule {
    [string]$name
    $eTag
    [string]$id

    [pscustomobject]$properties

    HuntingRule ($name, $eTag, $id, $properties ) {
        $this.name = $name
        $this.eTag = $eTag
        $this.id = $id
        $this.properties = $properties

    }
}

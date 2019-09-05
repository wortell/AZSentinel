function Compare-Policy {
    <#
    .SYNOPSIS
        coming soon
    .DESCRIPTION
        coming soon
    .PARAMETER ReferenceTemplate
        Coming soon
    .PARAMETER DifferenceTemplate
    Coming soon
    .EXAMPLE
    Compare-Policy -ReferenceTemplate $ref -DifferenceTemplate $diff

    .NOTES
    NAME: Compare-Policy
    #>

    [CmdletBinding()]
    param (
        # Reference value is the Online available
        [Parameter(Mandatory)]
        [psobject]$ReferenceTemplate,

        # Difference  template is the template that will be uploaded
        [Parameter(Mandatory)]
        [psobject]$DifferenceTemplate
    )

    process {
        $objprops = $ReferenceTemplate | Get-Member -MemberType Property, NoteProperty | ForEach-Object Name
        $objprops += $DifferenceTemplate | Get-Member -MemberType Property, NoteProperty | ForEach-Object Name
        $objprops = $objprops | Sort-Object -Unique | Select-Object

        $diffs = @()

        foreach ($objprop in $objprops) {
            $diff = Compare-Object $ReferenceTemplate $DifferenceTemplate -Property $objprop
            if ($diff) {
                $diffprops = @{
                    PropertyName = $objprop
                    RefValue     = ($diff | Where-Object { $_.SideIndicator -eq '<=' } | ForEach-Object $($objprop))
                    DiffValue    = ($diff | Where-Object { $_.SideIndicator -eq '=>' } | ForEach-Object $($objprop))
                }
                $diffs += New-Object PSObject -Property $diffprops
            }
        }
        if ($diffs) {
            return ($diffs | Select-Object PropertyName, RefValue, DiffValue)
        }
    }
}

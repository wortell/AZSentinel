#requires -version 6.2

function Compare-Policy {
    <#
    .SYNOPSIS
    Compare PS Objects
    .DESCRIPTION
    This function is used for  comparison to see if a rule needs to be updated
    .PARAMETER ReferenceTemplate
    Reference template is the data of the AlertRule as active on Azure
    .PARAMETER DifferenceTemplate
    Difference template is data that is generated and will be uploaded to Azure
    .EXAMPLE
    Compare-Policy -ReferenceTemplate  -DifferenceTemplate
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

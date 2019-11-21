$modulePath = "$PSScriptRoot\..\..\.."
$moduleName = Split-Path -Path $modulePath -Leaf

InModuleScope $moduleName {
    $ref = New-Object psobject -Property @{
        name = 'name'
        displayname = 'testdisplayname'
        prop1 = $true
        prop2 = 3
    }


    $obj1 = New-Object psobject -Property @{
        name = 'name'
        displayname = 'testdisplayname'
        prop1 = $true
        prop2 = 3
    }

    $obj2 = New-Object psobject -Property @{
        name = 'name2'
        displayname = 'testdisplayname'
        prop1 = $true
        prop2 = 4
    }

    Describe Get-ObjectMember {

        It 'Should return nothing because compare is same' {
            Compare-Policy -ReferenceTemplate $ref -DifferenceTemplate $obj1 | Should -BeNullOrEmpty

        }

        It 'Should return difference' {
            Compare-Policy -ReferenceTemplate $ref -DifferenceTemplate $obj2 | Should -Not -BeNullOrEmpty
        }
    }
}

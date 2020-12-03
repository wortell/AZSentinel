Describe "Testing mocking" {
    it "Mock test" {
        class Mock : ChocoClass {
            [string] FunctionToMock() { return "mystring" }
        }
        $package = New-Object Mock
        $expected = $package.OutputToOverwrite()
        $expected | should BeExactly "mystring"
    }
}



Describe ScheduledAlertProp {
    Context 'Constructors' {
        It 'Class groupingConfiguration has a constructor' {

            $groupingConfiguration = [groupingConfiguration]::new(
                $true,
                $false,
                "PT5H",
                "All",
                @(
                    "Account",
                    "Ip",
                    "Host",
                    "Url",
                    "FileHash"
                )
            )
            $groupingConfiguration | Should -Not -BeNullOrEmpty
        }
    }
    Context 'Constructors' {
        It 'Class IncidentConfiguration has a constructor' {

            $groupingConfiguration = [groupingConfiguration]::new(
                $true,
                $false,
                "PT5H",
                "All",
                @(
                    "Account",
                    "Ip",
                    "Host",
                    "Url",
                    "FileHash"
                )
            )
            $groupingConfiguration | Should -Not -BeNullOrEmpty


            $IncidentConfiguration = [IncidentConfiguration]::new(
                $true,
                $groupingConfiguration
            )
            $IncidentConfiguration  | Should -Not -BeNullOrEmpty
        }
    }
}

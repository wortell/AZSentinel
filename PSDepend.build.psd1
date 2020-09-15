@{
    # Set up a mini virtual environment...
    PSDependOptions = @{
        AddToPath = $true
        Target = 'BuildOutput/modules'
        Parameters = @{
        }
    }

    BuildHelpers      = 'latest'
    InvokeBuild       = 'latest'
    Pester            = '4.10.1'
    PSScriptAnalyzer  = 'latest'
    platyPS           = 'latest'
    PSDeploy          = 'latest'
    'Az.Accounts'     = '1.6.4'
}

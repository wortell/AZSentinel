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
    Pester            = 'latest'
    PSScriptAnalyzer  = 'latest'
    platyPS           = 'latest'
    PSDeploy          = 'latest'
    'Az.Accounts'     = '1.6.4'
}

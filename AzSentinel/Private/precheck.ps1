function precheck {
    <#
    .SYNOPSIS
    This function is used to cover the prechecks
    .DESCRIPTION
    This function is used to cover the prechecks
    .EXAMPLE
    precheck
    #>

    [cmdletbinding()]
    param (

    )
    try {
       if (! (Get-Module Az.accounts -ListAvailable)){
           Import-Module Az.Accounts -Force
       }
       else {
           Write-Verbose "Module is already loaded"
       }
    }
    catch {
        Write-Verbose $_.Exception.Message
        Write-Error "AZ Module needed for authentication" -ErrorAction Stop
    }
}

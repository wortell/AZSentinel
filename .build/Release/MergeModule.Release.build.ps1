param (
    [string] $ProjectName = 'AzSentinel',

    [string] $SourceFolder = $ProjectName,

    [string] $BuildOutput = (property BuildOutput 'C:\BuildOutput'),

    [string] $ModuleVersion = (property ModuleVersion $(
        if($resolvedModuleVersion = Get-NextNugetPackageVersion -Name $ProjectName -ErrorAction SilentlyContinue) {
            if ($resolvedModuleVersion -gt [version]'0.4.0') {
                $resolvedModuleVersion
            } else {
                '0.4.0'
            }
        } else {
            '0.4.0'
        }
        )),

    $MergeList = (property MergeList @('enum*','Class*','Priv*','Pub*') ),

    [string] $LineSeparation = (property LineSeparation ('-' * 78))

)

# Synopsis: Copy the Module Source files to the BuildOutput
Task Copy_Source_To_Module_BuildOutput {
    if (![io.path]::IsPathRooted($BuildOutput)) {
        $BuildOutput = Join-Path -Path $BuildRoot -ChildPath $BuildOutput
    }
    $BuiltModuleFolder = [io.Path]::Combine($BuildOutput,$ProjectName)
    "Copying $BuildRoot/$SourceFolder To $BuiltModuleFolder/"
    'enums', 'Classes', 'Private', 'Public' | ForEach-Object -Process {
        Get-Item -Path "$BuildRoot/$SourceFolder/$_" |
            Copy-Item -Destination "$BuiltModuleFolder/$_" -Recurse -Force -Exclude '*.bak','wip*'
    }
    Get-Item -Path "$BuildRoot/$SourceFolder/*.psd1" |
        Copy-Item -Destination "$BuiltModuleFolder/" -Force
}

# Synopsis: Merging the PS1 files into the PSM1.
Task Merge_Source_Files_To_PSM1 {
    if(!$MergeList) {$MergeList = @('enum*','Class*','Priv*','Pub*') }

    $mergePrint = $MergeList.ForEach{
        if ($_ | Get-Member -MemberType NoteProperty -Name Name){
            $_.Name
        } else {
            $_
        }
    } -join ', '

    "`tORDER: [$($mergePrint -join ', ')]`r`n"

    if (![io.path]::IsPathRooted($BuildOutput)) {
        $BuildOutput = Join-Path -Path $BuildRoot -ChildPath $BuildOutput
    }

    $BuiltModuleFolder = [io.Path]::Combine($BuildOutput,$ProjectName)
    # Merge individual PS1 files into a single PSM1, and delete merged files
    $OutModulePSM1 = [io.path]::Combine($BuiltModuleFolder,"$ProjectName.psm1")
    Write-Build Green "  Merging to $OutModulePSM1"
    $MergeList | Get-MergedModule -SourceFolder $BuiltModuleFolder | Out-File $OutModulePSM1 -Force
}

# Synopsis: Removing Empty folders from the Module Build output
Task Clean_Folders_from_Build_Output {

    if (![io.path]::IsPathRooted($BuildOutput)) {
        $BuildOutput = Join-Path -Path $BuildRoot -ChildPath $BuildOutput
    }

    $BuiltModuleFolder = [io.Path]::Combine($BuildOutput,$ProjectName)

    Get-ChildItem -Path $BuiltModuleFolder -Recurse -Force | Sort-Object -Property FullName -Descending | Where-Object {
        $_.PSIsContainer -and
        $_.GetDirectories().Count -eq 0
    } | Remove-Item -Recurse -Force
}

# Synopsis: Update the Module Manifest with the $ModuleVersion and setting the module functions
Task Update_Module_Manifest {
    if (![io.path]::IsPathRooted($BuildOutput)) {
        $BuildOutput = Join-Path -Path $BuildRoot -ChildPath $BuildOutput
    }

    $BuiltModule = [io.path]::Combine($BuildOutput,$ProjectName,"$ProjectName.psd1")
    Write-Build Green "  Updating Module functions in Module Manifest..."
    Set-ModuleFunctions -Path $BuiltModule -FunctionsToExport (gci "$BuildRoot/$SourceFolder/Public" ).BaseName
    if($ModuleVersion) {
        Write-Build Green "  Updating Module version in Manifest to $ModuleVersion"
        Update-Metadata -path $BuiltModule -PropertyName ModuleVersion -Value $ModuleVersion
    }
    ''
}

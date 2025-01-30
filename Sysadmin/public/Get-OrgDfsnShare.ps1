function Get-DfsnShare {
    param (
        [Parameter(Mandatory)]
        $NamespaceRoot
    )

    $DfsFolders = Get-DfsnFolder -Path "$NamespaceRoot\*" -ErrorAction Stop
    $ShareList = @()

    foreach ($Folder in $DfsFolders) {
        $Targets = Get-DfsnFolderTarget -Path $Folder.Path -ErrorAction SilentlyContinue

        foreach ($Target in $Targets) {
            $ShareList += [PSCustomObject]@{
                DFSPath = $Folder.Path
                TargetPath = $Target.TargetPath
            }
        }
    }

    return $ShareList
}

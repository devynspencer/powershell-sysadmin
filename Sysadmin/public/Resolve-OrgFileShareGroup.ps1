function Resolve-OrgFileShareGroup {
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -Path $_ })]
        [string[]]
        $Path
    )

    foreach ($FileSharePath in $Path) {
        # Get the directory name and parent directory name
        $DirectoryName = (Split-Path -Path $FileSharePath -Leaf)
        $ParentDirectoryName = (Split-Path -Path (Split-Path -Path $FileSharePath -Parent) -Leaf)

        return "FS - $ParentDirectoryName $DirectoryName"
    }
}

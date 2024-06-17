function Resolve-OrgFileShareGroup {
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -Path $_ })]
        [string]
        $Path
    )

    $DirectoryName = (Split-Path -Path $Path -Leaf)
    $ParentDirectoryName = (Split-Path -Path (Split-Path -Path $Path -Parent) -Leaf)

    return "FS - $ParentDirectoryName $DirectoryName"
}

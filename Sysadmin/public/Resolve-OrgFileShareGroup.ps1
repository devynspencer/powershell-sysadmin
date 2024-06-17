function Resolve-OrgFileShareGroup {
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -Path $_ })]
        [string[]]
        $Path
    )

    process {
        foreach ($FileSharePath in $Path) {
            # Get the directory name and parent directory name
            $DirectoryName = (Split-Path -Path $FileSharePath -Leaf)
            $ParentDirectoryName = (Split-Path -Path (Split-Path -Path $FileSharePath -Parent) -Leaf)

            return "FS - $ParentDirectoryName $DirectoryName"
        }
    }
}

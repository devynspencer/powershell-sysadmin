function Resolve-OrgFileShareGroup {
    param (
        # The path to the file share
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -Path $_ })]
        [string[]]
        $Path,

        # The type of access granted to the group
        [ValidateSet('Modify', 'Read')]
        $AccessType = 'Modify'
    )

    process {
        foreach ($FileSharePath in $Path) {
            # Get the directory name and parent directory name
            $DirectoryName = (Split-Path -Path $FileSharePath -Leaf)
            $ParentDirectoryName = (Split-Path -Path (Split-Path -Path $FileSharePath -Parent) -Leaf)

            # Build the group name
            $GroupName = "FS - $ParentDirectoryName $DirectoryName"

            # Add the access type as a suffix, if specified
            switch ($AccessType) {
                'Modify' {
                    # No suffix needed for Modify access
                }

                'Read' {
                    $GroupSuffix = "($AccessType)"
                    $GroupName = "$GroupName $GroupSuffix"
                }
            }

            # Return the group name
            $GroupName
        }
    }
}

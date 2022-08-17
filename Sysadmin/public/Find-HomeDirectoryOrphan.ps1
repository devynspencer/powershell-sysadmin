function Find-HomeDirectoryOrphan {
    param (
        # Path a home directory root (not an individual home directory)
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Validatescript({ Test-Path $_ })]
        [string[]]
        $Path
    )

    begin {
        $AllUsers = Get-ADUser -Filter * | select SamAccountName, HomeDirectory
    }

    process {
        foreach ($HomeDirectoryRoot in $Path) {
            Write-Verbose "Searching [$HomeDirectoryRoot] for home directories without a corresponding user in ADDS"

            $HomeDirectories = Get-ChildItem -Path $HomeDirectoryRoot -Directory
            $Orphans = $HomeDirectories | ? Name -NotIn $AllUsers.SamAccountName

            Write-Verbose "Found [$($HomeDirectories.Count)] directories"
            Write-Verbose "Found [$($Orphans.Count)] orphans"

            foreach ($OrphanDirectory in $Orphans) {
                # Check for user accounts that have a matching HomeDirectory attribute (likely
                # mismatched due to a name change on the account *without* updating the directory name)
                $Owner = $AllUsers | ? HomeDirectory -EQ $OrphanDirectory.FullName

                [pscustomobject] @{
                    Path = $OrphanDirectory.FullName
                    Owner = $Owner
                }
            }
        }
    }
}

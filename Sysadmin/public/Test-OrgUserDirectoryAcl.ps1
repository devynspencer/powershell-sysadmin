function Test-OrgUserDirectoryAcl {
    param (
        # Path to the user directory to test
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -Path $_ })]
        [string]
        $Path,

        # SamAccountName of the user to test
        [Parameter(Mandatory)]
        [string]
        $SamAccountName
    )

    # Get the ACL for the directory
    $Acl = Get-Acl -Path $Path

    # Define the expected ACL entries
    $ExpectedAclEntries = @(
        @{ IdentityReference = 'BUILTIN\Administrators'; FileSystemRights = 'FullControl' },
        @{ IdentityReference = 'NT AUTHORITY\SYSTEM'; FileSystemRights = 'FullControl' },
        @{ IdentityReference = $SamAccountName; FileSystemRights = 'Modify' }
    )

    # Get the actual ACL entries
    $ActualAclEntries = $Acl.Access | ForEach-Object {
        @{ IdentityReference = $_.IdentityReference.Value; FileSystemRights = $_.FileSystemRights }
    }

    # Compare ACL entries against expected entries. For performance, only the number of entries is
    # compared initially. If counts match, then each expected entry is compared against actual entries
    $IsExpectedCount = $ExpectedAclEntries.Count -eq $ActualAclEntries.Count

    if ($IsExpectedCount) {
        foreach ($ExpectedEntry in $ExpectedAclEntries) {
            # Compare each expected entry against actual entries
            $MatchingActualEntry = $ActualAclEntries | where {
                $_.IdentityReference -eq $ExpectedEntry.IdentityReference -and
                $_.FileSystemRights -eq $ExpectedEntry.FileSystemRights
            }

            # If an expected entry is not found, set flag and break loop
            if ($null -eq $MatchingActualEntry) {
                $IsExpectedCount = $false
                break
            }
        }
    }

    # Return whether all expected entries (and no others) were found
    return $IsExpectedCount
}

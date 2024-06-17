. "$PSScriptRoot\Resolve-OrgFileShareGroup.ps1"

function Test-OrgFileShareAcl {
    [CmdletBinding(DefaultParameterSetName = 'ByPath')]
    param (
        # The name of the file share to test
        [Parameter(Mandatory, ParameterSetName = 'ByShareName')]
        [string]
        $ShareName,

        # Expected owner of the file share
        $ShareOwner = 'BUILTIN\Administrators',

        # NetBIOS name of domain (prefix for domain groups on ACL entries)
        $NetBiosName = (Get-ADDomain).NetBIOSName,

        # Path to file share
        [Parameter(Mandatory, ParameterSetName = 'ByPath')]
        [ValidateScript({ Test-Path -Path $_ })]
        $Path
    )

    # TODO: Handle other access types

    # Resolve the access group name for the share
    $ModifyGroupName = Resolve-OrgFileShareGroup -Path $Path

    # Define the expected ACL entries
    $ExpectedAcl = @(
        @{ FileSystemRights = 'FullControl'; IdentityReference = 'BUILTIN\Administrators' }
        @{ FileSystemRights = 'FullControl'; IdentityReference = 'NT AUTHORITY\SYSTEM' }
        @{ FileSystemRights = 'Modify, Synchronize'; IdentityReference = "$NetBiosName\$ModifyGroupName" }
    )

    # Get the actual ACL for the file share
    $Acl = Get-Acl -Path $Path

    # Compare the expected ACL entries against the actual ACL entries
    foreach ($ExpectedEntry in $ExpectedAcl) {
        Write-Verbose "[Test-OrgFileShareAcl] Checking for $($ExpectedEntry.IdentityReference) with $($ExpectedEntry.FileSystemRights) permissions"

        $MatchingActualEntry = $Acl.Access | where {
            $_.IdentityReference.Value -eq $ExpectedEntry.IdentityReference -and
            $_.FileSystemRights -eq $ExpectedEntry.FileSystemRights
        }

        # If an expected entry is not found, return false immediately
        if ($null -eq $MatchingActualEntry) {
            return $false
        }
    }
}

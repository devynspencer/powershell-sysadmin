function Clear-AclOrphanEntry {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $Path

        # TODO: Add support for other unwanted identities like CREATOR OWNER, Everyone, and Authenticated Users
    )

    process {
        foreach ($Directory in $Path) {
            $Acl = Get-Acl -Path $Directory

            # Only modify ACL if changes required
            $AclUpdated = $false

            Write-Verbose "Current directory is [$Directory]`n-------------------"
            Write-Verbose "Previewing ($($Acl.Access.Count)) identities (original)"
            Write-Verbose (($Acl.Access.IdentityReference.Value | sort) -join ', ')

            # Check for orphan identities on ACL of current directory
            foreach ($Entry in $Acl.Access) {
                $Identity = $Entry.IdentityReference.Value

                if ($Identity -like 'S-1-5-*') {
                    Write-Verbose "Found orphan identity [$Identity]`n"
                    $Acl.RemoveAccessRule($Entry) | Out-Null

                    # Ensure changes are applied
                    $AclUpdated = $true
                }
            }

            Write-Verbose "Previewing ($($Acl.Access.Count)) identities (updated)"
            Write-Verbose (($Acl.Access.IdentityReference.Value | sort) -join ', ')

            # Apply changes if orphan identities found
            if ($AclUpdated -and $PSCmdlet.ShouldProcess($Directory, 'Apply changes to ACL')) {
                Set-Acl -Path $Directory -AclObject $Acl -Verbose
            }

            Write-Verbose ''
        }
    }
}

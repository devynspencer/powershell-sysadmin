function Repair-OrgUserDirectoryAcl {
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -Path $_ })]
        [string[]]
        $Path
    )

    foreach ($UserDirectory in $Path) {
        Write-Verbose "[Reset-OrgUserDirectoryAcl] processing directory [$UserDirectory]"

        # Verify a matching user account exists for the current directory
        $ExpectedAccountName = (Split-Path -Path $UserDirectory -Leaf).ToLower()
        Write-Verbose "[Reset-OrgUserDirectoryAcl] checking for account [$ExpectedAccountName] based on directory name"

        # Attempt to resolve the owner's user account from Active Directory
        try {
            # Include office location for later comparison against home directory location
            $UserParams = @{
                Identity = $ExpectedAccountName
                Properties = 'DisplayName', 'Description', 'Office', 'HomeDirectory', 'Title'
                ErrorAction = 'Stop'
            }

            $UserAccount = Get-ADUser @UserParams | select $UserParams.Properties
        }

        catch {
            Write-Warning $Error[0]
            # TODO: Handle bullshit errors from ActiveDirectory module
        }

        # Skip the current directory if no matching user account is found
        if (!$UserAccount) {
            Write-Verbose "[Reset-OrgUserDirectoryAcl] user account [$ExpectedAccountName] not found in Active Directory, skipping..."
            break
        }

        Write-Verbose "[Reset-OrgUserDirectoryAcl] user account [$ExpectedAccountName] found in Active Directory: $($UserAccount | ConvertTo-Json -Compress)"

        # TODO: Handle variations of current path elegently (i.e. a PowerShell provider path, UNC path, etc.),
        #   to avoid false positives when comparing against the HomeDirectory attribute
        #
        # Skip the current directory if different from home directory listed on user account
        if ($UserDirectory -ne $UserAccount.HomeDirectory) {
            Write-Warning "[Reset-OrgUserDirectoryAcl] HomeDirectory attribute [$($UserAccount.HomeDirectory)] of user account [$ExpectedAccountName] doesn't match current directory, skipping..."
            break
        }

        # Establish shared parameters for each execution of Start-Process
        $SharedParams = @{
            FilePath = 'icacls.exe'
            Wait = $true
            NoNewWindow = $true
        }

        # Reset ACLs
        Start-Process @SharedParams -ArgumentList "`"$UserDirectory`"", '/reset', '/t'

        # Apply baseline permissions
        Start-Process @SharedParams -ArgumentList "`"$UserDirectory`"", '/inheritance:r', '/grant:r', 'SYSTEM:(OI)(CI)(F)', 'Administrators:(OI)(CI)(F)'

        # Apply user permissions
        Start-Process @SharedParams -ArgumentList "`"$UserDirectory`"", '/inheritance:r', '/grant:r', "$ExpectedAccountName`:(OI)(CI)(M)"
    }
}

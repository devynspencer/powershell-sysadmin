# TODO: Add support for multiple parameter sets

function Get-OrgUser {
    param (
        # User name to query ANR
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName')]
        [string[]]
        $Name,

        # Display user group membership, limited to the top n groups based on total membership count.
        # This allows more relevant groups to be shown first.
        [ValidateRange(1, 10)]
        $GroupLimit = 5,

        # Include all results, even those missing required properties for *user* accounts (i.e. not service accounts)
        [switch]
        $All

        # TODO: Add filter parameters for properties, i.e. Title, Department, Office, LastLogonDate
    )

    process {
        foreach ($NamePartial in $Name) {
            Write-Verbose "Attempting to resolve account(s) from name [$NamePartial] using ANR"

            # Single quotes are intentional, workaround for the shit pile that is filtering with Get-ADUser
            # https://stackoverflow.com/questions/20075502/get-aduser-filter-will-not-accept-a-variable
            $AccountMatches = Get-ADUser -Filter "ANR -eq `"$NamePartial`"" -Properties Name, Title, Department, Office, OfficePhone, MobilePhone, EmailAddress, Manager, SamAccountName, MemberOf, HomeDirectory, LockedOut, PasswordExpired, Created, Modified, LastLogonDate

            Write-Verbose "Matched [$($AccountMatches.Count)] user accounts"

            # Skip accounts missing basic user attributes, unless All switch specified. Testing
            # for either HomeDirectory/EmailAddress/MobilePhone/OfficePhone as likely indicators of
            # an actual user account.
            if (!$All) {
                $AccountMatches = $AccountMatches | where { $_.HomeDirectory -or $_.EmailAddress -or $_.MobilePhone -or $_.OfficePhone }
            }

            # Iterating through results of Get-ADUser as the ANR filter may return multiple results
            foreach ($Account in $AccountMatches) {
                $AccountAge = '{0:N2}' -f ((New-TimeSpan -Start $Account.Created).Days / 365)
                $PhoneNumbers = @($Account.OfficePhone, $Account.MobilePhone) | sort -Unique

                # Exclude stupid mail-enabled security groups
                $Groups = $Account.MemberOf | Get-ADGroup -Properties SamAccountName, Members, mail | where { !$_.mail } | select SamAccountName, @{n = 'MemberCount'; e = {$_.Members.Count}}

                $Manager = Get-ADUser -Properties EmailAddress -Identity $Account.Manager -ErrorAction 0

                # Return user object
                $Output = [ordered] @{
                    Name = $Account.Name
                    Title = $Account.Title
                    Department = $Account.Department
                    Office = $Account.Office
                    PhoneNumbers = $PhoneNumbers
                    EmailAddress = $null
                    Manager = $null
                    SamAccountName = $Account.SamAccountName.ToLower()
                    Groups = ($Groups | sort MemberCount -Descending -Top $GroupLimit).SamAccountName
                    HomeDirectory = $Account.HomeDirectory
                    Created = $Account.Created
                    AccountAge = $AccountAge
                    Modified = $Account.Modified
                    LastLogonDate = $Account.LastLogonDate

                    # TODO: Add these properties conditionally if a AuthInfo flag or similar specified?
                    LockedOut = $Account.LockedOut
                    PasswordExpired = $Account.PasswordExpired
                }

                # Handle potentially null properties in the least succinct way possible
                if ($Account.EmailAddress) {
                    $Output.EmailAddress = $Account.EmailAddress.ToLower()
                }

                # TODO: Should this be a separate ManagerEmail/ManagerEmailAddress property?
                # Property name (following convention) way too long; would also reduce total properties
                if ($Manager) {
                    $Output.Manager = $Manager.EmailAddress.ToLower()
                }

                # Return user object
                [pscustomobject] $Output
            }
        }
    }
}

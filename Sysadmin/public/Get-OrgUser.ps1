function Get-OrgUser {
    param (
        # User identity to search for
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]
        $Identity
    )

    begin {
        $DisplayProperties = @(
            'Department'
            'Description'
            'DisplayName'
            'Division'
            'EmailAddress'
            'EmployeeID'
            'EmployeeNumber'
            'Enabled'
            'GivenName'
            'HomeDirectory'
            'LastLogonDate'
            'LockedOut'
            'LogonWorkstations'
            'Manager'
            'managedObjects'
            'MemberOf'
            'MobilePhone'
            'Modified'
            'Name'
            'Office'
            'OfficePhone'
            'PasswordExpired'
            'SamAccountName'
            'StreetAddress'
            'Surname'
            'Title'
            'UserPrincipalName'
        )
    }

    process {
        foreach ($UserIdentity in $Identity) {
            $Account = Get-ADUser -Identity $UserIdentity -Properties $DisplayProperties | select $DisplayProperties

            $Account
        }
    }
}

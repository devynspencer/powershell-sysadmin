<#
    .SYNOPSIS
        Find inactive Active Directory account(s) by last logon timestamp.

    .DESCRIPTION
        Find inactive Active Directory account(s) by last logon timestamp. Also supports a variety of criteria for excluding service accounts or other non-user accounts.

    .PARAMETER LastLogonDays
        Number of days since last logon to include in the initial search for accounts.

    .PARAMETER ExcludeCriteria
        Exclude account objects meeting specific criteria:

            AnyServicePrincipalNames - Exclude accounts with one or more service principle names defined
            HasCannotChangePassword - Exclude accounts with 'CannotChangePassword' set
            HasPasswordNeverExpires - Exclude accounts with 'PasswordNeverExpires' set
            HasPasswordNotRequired - Exclude accounts with 'PasswordNotRequired' set
            HasTrustedForDelegation - Exclude accounts with 'TrustedForDelegation' set
            MissingEmailAddress - Exclude accounts without an email address
            MissingHomeDirectory - Exclude accounts without a home directory

    .EXAMPLE
        Find-InactiveAccount -ExcludeCriteria 'AnyServicePrincipalNames', 'MissingHomeDirectory'
#>

function Find-InactiveAccount {
    [CmdletBinding()]
    param (
        $LastLogonDays = 90,

        [ValidateSet(
            'AnyServicePrincipalNames',
            'HasCannotChangePassword',
            'HasPasswordNeverExpires',
            'HasPasswordNotRequired',
            'HasTrustedForDelegation',
            'MissingEmailAddress',
            'MissingHomeDirectory'
        )]
        [string[]]
        $ExcludeCriteria
    )

    $AllUserObjects = Get-ADUser -Filter * -Properties @(
        'CannotChangePassword',
        'Description',
        'EmailAddress',
        'HomeDirectory',
        'LastLogonDate',
        'PasswordNeverExpires',
        'PasswordNotRequired',
        'ServicePrincipalNames',
        'TrustedForDelegation'
    )

    $AllUsers = $AllUserObjects.where({ $_.LastLogonDate -lt (Get-Date).AddDays(-$LastLogonDays) })
    $ExcludedUserNames = @()

    if ($ExcludeCriteria -contains 'AnyServicePrincipalNames') {
        $AllUsers.where({ $_.ServicePrincipleNames }).foreach({ $ExcludedUserNames += $_.SamAccountName })
    }

    if ($ExcludeCriteria -contains 'HasCannotChangePassword') {
        $AllUsers.where({ $_.CannotChangePassword }).foreach({ $ExcludedUserNames += $_.SamAccountName })
    }

    if ($ExcludeCriteria -contains 'HasPasswordNeverExpires') {
        $AllUsers.where({ $_.PasswordNeverExpires }).foreach({ $ExcludedUserNames += $_.SamAccountName })
    }

    if ($ExcludeCriteria -contains 'HasPasswordNotRequired') {
        $AllUsers.where({ $_.PasswordNotRequired }).foreach({ $ExcludedUserNames += $_.SamAccountName })
    }

    if ($ExcludeCriteria -contains 'HasTrustedForDelegation') {
        $AllUsers.where({ $_.TrustedForDelegation }).foreach({ $ExcludedUserNames += $_.SamAccountName })
    }

    if ($ExcludeCriteria -contains 'MissingEmailAddress') {
        $AllUsers.where({ !$_.EmailAddress }).foreach({ $ExcludedUserNames += $_.SamAccountName })
    }

    if ($ExcludeCriteria -contains 'MissingHomeDirectory') {
        $AllUsers.where({ !$_.HomeDirectory }).foreach({ $ExcludedUserNames += $_.SamAccountName })
    }

    $InactiveUsers = $AllUsers.where({ $_.SamAccountName -notin $ExcludedUserNames }) |
        select LastLogonDate, Name, SamAccountName, HomeDirectory, Description |
        sort LastLogonDate -Descending

    return $InactiveUsers
}

function Get-UserMembership {
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $SamAccountName,

        [ValidateSet('Security', 'Distribution')]
        $GroupCategory = @('Security', 'Distribution')
    )

    $User = Get-ADUser -Identity $SamAccountName -Properties MemberOf

    $GroupProperties = @(
        'DisplayName'
        'Description'
        'Members'
        'GroupCategory'
        'GroupScope'
        'Created'
        'Modified'
        'ManagedBy'
    )

    $Groups = $User.Memberof | Get-ADGroup -Properties $GroupProperties | where GroupCategory -In $GroupCategory

    $Groups | select GroupCategory, GroupScope, Created, Modified, @{n = 'MemberCount'; e = {$_.Members.Count}}, SamAccountName, DisplayName, Description, @{n = 'ManagerName'; e = {$_.ManagedBy.Split(',')[0].Replace('CN=', '')}} | sort GroupCategory, SamAccountName -Descending
}

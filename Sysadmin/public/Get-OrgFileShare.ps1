function Get-OrgFileShare {
    param (
        # TODO: Support file objects as well...
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ByPath')]
        [string[]]
        $Path
    )

    process {
        foreach ($SharePath in $Path) {
            # Resolve share, site, and group names
            $ShareName = $SharePath | Split-Path -Leaf
            $SiteName = $SharePath | Split-Path -Parent | Split-Path -Leaf
            $GroupName = "FS - $SiteName $ShareName"

            # Check if group exists already
            Write-Verbose "Checking for existing group: [$GroupName]"
            $GroupExists = Get-ADGroup -Identity $GroupName -ErrorAction 0

            # Search share permissions for corresponding share group (based on naming standard)
            $Acl = Get-Acl -Path $Path

            foreach ($Entry in $Acl.Access.IdentityReference) {
                $CurrentIdentity = ($Entry -split '\\')[-1]
                Write-Verbose "Current ACL entry: $Entry ($CurrentIdentity)"

                if ($CurrentIdentity -eq $GroupName) {
                    Write-Verbose "Matching share group found! [$GroupName]`n"
                    $Group = $CurrentIdentity
                    break
                }
            }

            # Return the share object
            [pscustomobject] @{
                Name = $ShareName
                Site = $SiteName
                Path = $SharePath
                GroupName = $GroupName
                GroupExists = [bool] $GroupExists
                HasGroup = [bool] $Group
                Owner = $Acl.Owner
                Access = $Acl.Access
            }

            # Cleanup found group
            $Group = $null
        }
    }
}

function Get-OrgFileShare {
    param (
        # TODO: Support file objects as well...
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ByPath')]
        [string[]]
        $Path,

        # Formatting rules to apply to share name before generating the final share group name
        #
        #   - StripHyphen: Remove hyphen characters, i.e. a site name of "SomeSite" and a share name of
        #       "Section - A" would yield "FS - SomeSite Section A" instead of "FS - SomeSite Section - A"
        #
        #   - StripAmpersand: Remove ampersand characters, i.e. a site name of "SomeSite" and a share name of
        #       "A & B" would yield "FS - SomeSite A B" instead of "FS - SomeSite A & B"
        #
        [ValidateSet('StripHypen', 'StripAmpersand')]
        [string[]]
        $FormatRules = @('StripHyphen')
    )

    process {
        foreach ($SharePath in $Path) {
            # Resolve share, site, and group names
            $ShareName = $SharePath | Split-Path -Leaf
            $SiteName = $SharePath | Split-Path -Parent | Split-Path -Leaf

            # Handle formatting rules
            switch ($FormatRules) {
                'StripHyphen' {
                    $ShareName = $ShareName -replace '\s+-\s+', ' '
                }

                'StripAmpersand' {
                    $ShareName = $ShareName -replace '\s+&\s+', ' '
                }
            }

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
                    $MatchingGroup = $CurrentIdentity
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
                GroupAdded = [bool] $MatchingGroup
                Owner = $Acl.Owner
                Access = $Acl.Access
            }

            # Cleanup found group
            $Group = $null
        }
    }
}

function New-OrgFileShareGroup {
    param (
        # TODO: Add parameter set to handle specifying a share name explicitly instead of querying file servers

        # File servers to query existing SMB shares from
        [Parameter(Mandatory)]
        $ComputerName,

        # Active Directory OU to create share group in
        [Parameter(Mandatory)]
        $Path,

        # Level of access provided by the group
        [ValidateSet('Read', 'Modify', 'Contribute')]
        $Access = 'Modify',

        # User or principal to associate with the share group
        $ManagedBy,

        [switch]
        $PassThru,

        [switch]
        $WhatIf,

        # Regex matching names of shares to skip
        $ExcludePattern = '\$|Files|Users|Printers|Video|Home'
    )

    # Get file shares, excluding any admin/hidden/DFS structure shares
    $Sessions = New-CimSession -ComputerName $ComputerName
    $FileShares = Get-SmbShare -CimSession $Sessions | ? Name -NotMatch $ExcludePattern

    foreach ($Share in $FileShares) {
        Write-Verbose "[New-OrgFileShareGroup] Building correct share name for [$($Share.Name)]"

        # Format security group name and description
        $Sanitized = $Share.Name -replace "[^a-zA-Z0-9\s&'-]+", ' ' -replace '\s\s+', ' '

        # Assumes share names are structures as "SITE - SHARE NAME"
        $NamePrefix = $Sanitized.Split(' - ')[0]
        $NameSuffix = $Sanitized.Split(' - ')[-1]

        # Build group parameters
        $GroupParams = @{
            Name = "FS - $NamePrefix $NameSuffix"
            Path = $Path
            Description = "Provides $Access access for file share $($Share.Name)"
            GroupCategory = 'Security'
            GroupScope = 'Global'
            ManagedBy = $ManagedBy
            PassThru = $PassThru
            WhatIf = $WhatIf
        }


        Write-Verbose "[New-OrgFileShareGroup] Sanitized share name is [$Sanitized]`nPrefix is [$NamePrefix]`nSuffix is [$NameSuffix]"
        Write-Verbose "[New-OrgFileShareGroup] Group name is [$($GroupParams.Name)]"

        # Ensure subsequent runs are idempotent
        if (!(Get-ADGroup $GroupParams.Name -ErrorAction 0)) {
            Write-Verbose "[New-OrgFileShareGroup] Creating share management group in $Path`n"
            Write-Verbose "[New-OrgFileShareGroup] Name: $($GroupParams.Name)`nDescription: $($GroupParams.Description)`n"
            New-ADGroup @GroupParams
        }

        else {
            Write-Verbose "[New-OrgFileShareGroup] Share management group already exists: $($GroupParams.Name)`n"
        }
    }
}

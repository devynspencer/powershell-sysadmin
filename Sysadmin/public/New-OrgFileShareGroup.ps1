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
        # Format security group name and description
        $Sanitized = $Share.Name -replace "[^a-zA-Z0-9\s-&']+", ' ' -replace '\s\s+', ' '
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

        # Ensure subsequent runs are idempotent
        if (!(Get-ADGroup $GroupParams.Name -ErrorAction 0)) {
            Write-Host -ForegroundColor DarkCyan "Creating share management group in $Path`n"
            Write-Host -ForegroundColor Cyan "Name: $($GroupParams.Name)`nDescription: $($GroupParams.Description)`n"
            New-ADGroup @GroupParams
        }

        else {
            Write-Host -ForegroundColor Magenta "Share management group already exists: $($GroupParams.Name)`n"
        }
    }
}

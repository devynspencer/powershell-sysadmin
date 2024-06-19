Function Get-MsiData {
    param (
        # Path to the MSI file
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [IO.FileInfo[]]
        $FilePath,

        $Query = 'SELECT * FROM Property'
    )

    begin {
        $InstallerHandle = New-Object -ComObject WindowsInstaller.Installer

        Write-Verbose "[Get-MsiData] Created Installer handle [$InstallerHandle]"
    }

    process {
        try {
            Write-Verbose "[Get-MsiData] Getting data from MSI [$($FilePath) using query [$Query]"

            $Properties = @{}

            # Create a connection to the properties database
            $Database = $InstallerHandle.GetType().InvokeMember('OpenDatabase', 'InvokeMethod', $null, $InstallerHandle, @("$FilePath", 0))

            # Query the database for all properties
            $View = $Database.GetType().InvokeMember('OpenView', 'InvokeMethod', $null, $Database, ($Query))
            $View.GetType().InvokeMember('Execute', 'InvokeMethod', $null, $View, $null)

            # Fetch the first record
            $Record = $View.GetType().InvokeMember('Fetch', 'InvokeMethod', $null, $View, $null)

            while ($null -ne $Record) {
                $PropertyName = $Record.GetType().InvokeMember('StringData', 'GetProperty', $null, $Record, 1)
                $PropertyValue = $Record.GetType().InvokeMember('StringData', 'GetProperty', $null, $Record, 2)
                $Properties[$PropertyName] = $PropertyValue

                # Attempt to get next record
                $Record = $View.GetType().InvokeMember('Fetch', 'InvokeMethod', $null, $View, $null)
            }

            Write-Verbose "[Get-MsiData] Found [$($Properties.Count)] properties in [$($FilePath)]"

            # Return the properties as a custom object
            [pscustomobject] $Properties
        }

        catch {
            throw "[Get-MsiData] Failed to get data from MSI [$($_)])"
        }
    }

    end {
        Write-Verbose "[Get-MsiData] Releasing Windows Installer handle [$InstallerHandle]"

        [System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject] $InstallerHandle) | Out-Null
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
    }
}

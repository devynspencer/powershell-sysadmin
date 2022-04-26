<#
.SYNOPSIS
    Retrieve installation properties for an MSI file.

.PARAMETER FilePath
    Filesystem path to MSI file

.EXAMPLE
    Get-InstallProperty -FilePath ~\Downloads\PowerShell-7.1.3-win-x64.msi
    Retrieve install properties for an MSI file.

.NOTES
    Based on the work of guyrleech, original code here available on GitHub here:

    https://github.com/guyrleech/Microsoft/blob/master/Get%20MSI%20Properties.ps1
#>
Function Get-InstallProperty {
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path $_ })]
        [string[]]
        $FilePath
    )

    begin {
        $WindowsInstaller = New-Object -Com WindowsInstaller.Installer

    }

    process {
        foreach ($File in $FilePath) {
            Write-Verbose "Getting installation properties for file [$File]"

            try {
                $Database = $WindowsInstaller.GetType().InvokeMember('OpenDatabase', 'InvokeMethod', $null, $WindowsInstaller, @($File, 0)) # 0 = open read-only
            }

            catch {
                $Database = $null
                Write-Error -Exception $_.Exception
            }

            if ($Database) {
                $PropertyData = @{}

                # Include all properties by default
                $Query = 'SELECT * FROM Property'

                # Build a view of installer properties based on database query
                if ($View = $Database.GetType().InvokeMember('OpenView', 'InvokeMethod', $null, $Database, $Query)) {
                    $View.GetType().InvokeMember('Execute', 'InvokeMethod', $null, $View, $null)

                    # Collect all property records into a hashtable
                    while ($Records = $View.GetType().InvokeMember('Fetch', 'InvokeMethod', $null, $View, $null)) {
                        $Name = $Records.GetType().InvokeMember('StringData', 'GetProperty', $null, $Records, 1)
                        $Value = $Records.GetType().InvokeMember('StringData', 'GetProperty', $null, $Records, 2)
                        $PropertyData.$Name = $Value
                    }

                    Write-Verbose "Found [$($PropertyData.Count)] properties in install file database"

                    # Return installer properties as a single object (one object per MSI file)
                    [pscustomobject] $PropertyData

                    # Cleanup current view
                    $View.GetType().InvokeMember('Close', 'InvokeMethod', $null, $View, $null)
                    $null = [System.Runtime.InteropServices.Marshal]::ReleaseComObject($View)
                }
            }
        }

        # Cleanup database for current MSI file
        $null = [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Database)
    }

    end {
        # Cleanup Windows Installer handler
        $null = [System.Runtime.InteropServices.Marshal]::ReleaseComObject($WindowsInstaller)
    }
}

function Get-DiskUsage {
    [CmdletBinding(DefaultParameterSetName = 'ByVolumeName')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]
        $ComputerName,

        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'ByVolumeName')]
        [string[]]
        $VolumeName,

        [Parameter(ParameterSetName = 'ByVolumeLetter')]
        [ValidatePattern('[\w]')]
        [string[]]
        $VolumeLetter,

        [switch]
        $IncludeShares
    )

    begin {
        $RemoteParams = @{}

        if ($PSBoundParameters.ContainsKey('Credential')) {
            $RemoteParams.Credential = $Credential
        }
    }

    process {
        foreach ($Computer in $ComputerName) {
            $Session = New-CimSession @RemoteParams -ComputerName $Computer

            # Include local volumes only for now -- disks with a value for ProviderName appear
            # to be mapped drives
            $DiskInfo = Get-CimInstance -CimSession $Session -ClassName Win32_LogicalDisk |
                Where-Object { $_.Size -and !$_.ProviderName }

            switch ($PSCmdlet.ParameterSetName) {
                'ByVolumeName' {
                    if ($PSBoundParameters.ContainsKey('VolumeName')) {
                        $DiskInfo = $DiskInfo |
                            Where-Object { $_.VolumeName -In $VolumeName }
                    }
                }

                'ByVolumeLetter' {
                    if ($PSBoundParameters.ContainsKey('VolumeLetter')) {
                        $DiskInfo = $DiskInfo |
                            Where-Object { $_.DeviceID.Replace(':', '') -In $VolumeLetter }
                    }
                }
            }


            foreach ($Disk in $DiskInfo) {
                $TotalUsed = $Disk.Size - $Disk.FreeSpace

                [pscustomobject] @{
                    ComputerName = $Computer
                    VolumeName = $Disk.VolumeName
                    VolumeLetter = $Disk.DeviceID.Replace(':', '')
                    Description = $Disk.Description
                    SerialNumber = $Disk.VolumeSerialNumber
                    FileSystem = $Disk.FileSystem
                    PercentUsed = [Math]::Round(($TotalUsed / $Disk.Size) * 100, 2)
                    PercentFree = [Math]::Round(($Disk.FreeSpace / $Disk.Size) * 100, 2)
                    TotalFreeGB = [Math]::Round($Disk.FreeSpace / 1GB, 2)
                    TotalUsedGB = [Math]::Round($TotalUsed / 1GB, 2)
                }
            }
        }
    }
}

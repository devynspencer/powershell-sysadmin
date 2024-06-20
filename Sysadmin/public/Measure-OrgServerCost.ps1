function Measure-OrgServerCost {
    param (
        [Parameter(Mandatory)]
        [string[]]
        $ComputerName,

        # Billing rates for a single server instance
        [float]
        $ServerRate = '0.00',

        # Billing rates for a single CPU core
        [float]
        $CpuRate = '0.00',

        # Billing rates for a single GB of memory
        [float]
        $MemoryRate = '0.00',

        # Billing rates for a single GB of storage
        [float]
        $StorageRate = '0.00',

        # List of storage volumes to exclude from billing calculations
        $ExcludeStorageVolume = @('C:')
    )

    foreach ($Server in $ComputerName) {
        # Create a CIM session to the server
        $CimSession = New-CimSession -ComputerName $Server

        # Collect general information
        $ActiveDirectoryObj = Get-ADComputer -Identity $Server -Properties Description
        $OperatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $CimSession

        # Collect processor information
        $Processor = Get-CimInstance -ClassName Win32_Processor -CimSession $CimSession

        # Collect memory information
        $PhysicalMemory = (Get-CimInstance -ClassName CIM_PhysicalMemory -CimSession $CimSession).Capacity / 1GB

        # Collect storage information
        $StorageFilter = 'DriveType = 3 ' + ($ExcludeStorageVolume.foreach({ "and DeviceID != `"$_`"" }) -join ' ')
        $Storage = Get-CimInstance -ClassName Win32_LogicalDisk -CimSession $CimSession -Filter $StorageFilter.Trim()

        # Build the output object
        $OutputObj = [ordered] @{
            ComputerName = $Server.ToUpper()
            Description = $ActiveDirectoryObj.Description
            OperatingSystem = $OperatingSystem.Caption
            Version = $OperatingSystem.Version
            CpuCores = ($Processor.NumberOfCores | measure -Sum).Sum
            CpuCoresLogical = ($Processor.NumberOfLogicalProcessors | measure -Sum).Sum
            CpuCoresEnabled = ($Processor.NumberOfEnabledCore | measure -Sum).Sum
            MemoryTotal = $PhysicalMemory
            StorageTotal = ($Storage.Size | measure -Sum).Sum / 1GB
        }

        # Calculate aggregate values
        $OutputObj.ServerCost = [Math]::Round($ServerRate, 2)
        $OutputObj.CpuCost = [Math]::Round($OutputObj.CpuCores * $CpuRate, 2)
        $OutputObj.MemoryCost = [Math]::Round($OutputObj.MemoryTotal * $MemoryRate, 2)
        $OutputObj.StorageCost = [Math]::Round($OutputObj.StorageTotal * $StorageRate, 2)
        $OutputObj.CostTotal = [Math]::Round($OutputObj.ServerCost + $OutputObj.CpuCost + $OutputObj.MemoryCost + $OutputObj.StorageCost, 2)

        # Output the results to the pipeline
        [pscustomobject] $OutputObj
    }
}

function Enable-RemoteRPC {
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $ComputerName,

        [switch]
        $PassThru
    )

    process {
        foreach ($Computer in $ComputerName) {
            $RegParams = @{
                Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
                Name = 'AllowRemoteRPC'
            }

            if ((Get-ItemProperty @RegParams).AllowRemoteRPC -ne 1) {
                Write-Verbose "Enabling remote RPC on [$Computer]"

                Set-ItemProperty @RegParams -Value 1
            }

            if ($PassThru) {
                Get-ItemProperty @RegParams
            }
        }
    }
}

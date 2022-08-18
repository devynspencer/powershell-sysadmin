function Skip-Unreachable {
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]
        $ComputerName,

        [int]
        $ThrottleLimit = 25,

        [int]
        $TimeoutSeconds = 3
    )

    process {
        $ComputerName | ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel {
            $ConnectParams = @{
                TargetName = $_
                Quiet = $true
                Count = 1
                TimeoutSeconds = $using:TimeoutSeconds
                ErrorAction = 'SilentlyContinue'
            }

            if (Test-Connection @ConnectParams) {
                $_
            }
        }
    }
}

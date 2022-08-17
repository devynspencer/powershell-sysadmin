function Close-RemoteSession {
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $ComputerName,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [int]
        $SessionId
    )

    # TODO: I'm unsure about pipeline support for something with specifics like a per-host session id that might change. Can each ComputerName pass a unique SessionId? Otherwise rewrite as a non-pipeline function I guess
    process {
        foreach ($Computer in $ComputerName) {
            if (!(Test-Connection $Computer -Quiet -Count 1)) {
                $ErrorParams = @{
                    Message = "Unable to reach [$Computer], skipping..."
                    Category = 'ConnectionError'
                    TargetObject = $Computer
                }

                Write-Error @ErrorParams

                return
            }

            # Clear the session
            $ExecParams = @{
                FilePath = 'rwinsta.exe'
                ArgumentList = @("/server:$Computer", $SessionId, '/v')
            }
        }
    }
}

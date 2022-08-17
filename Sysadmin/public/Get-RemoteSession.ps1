function Get-RemoteSession {
    param (
        # Hosts to query session information from
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]
        $ComputerName
    )

    begin {
        # Skip unreachable hosts
        $ReachableHosts = $ComputerName | ? { Test-Connection $_ -Quiet -Count 1 }
    }

    process {
        foreach ($Computer in $ReachableHosts) {
            # Query host for remote sessions, skipping the first (header) line

            # TODO: Start-Process punts the output for some reason
            # https://stackoverflow.com/questions/8761888/capturing-standard-out-and-error-with-start-process

            $Output = qwinsta /server:$Computer | select -Skip 1

            # Extract session data from each line of output
            foreach ($Line in $Output) {
                $HeaderFields = 'SessionName', 'UserName', 'Id', 'State', 'Type', 'Device'

                # Convert fixed-width fields into CSV format. Note the leading space (thus 2 spaces
                # minimum) and that each line can potentially have *multiple* blank columns (thus 19
                # characters maximum)
                $Session = $Line -replace '\s{2,19}', ',' | ConvertFrom-Csv -Header $HeaderFields

                [pscustomobject] @{
                    ComputerName = $Computer
                    SessionName = $Session.SessionName
                    UserName = $Session.UserName
                    SessionId = $Session.Id
                    State = $Session.State
                    Type = $Session.Type
                    Device = $Session.Device
                }
            }
        }
    }
}

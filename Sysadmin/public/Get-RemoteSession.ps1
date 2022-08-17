function Get-RemoteSession {
    param (
        # Hosts to query session information from
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]
        $ComputerName
    )

    begin {
        # Resolve session state parameter to actual/shorthand value
        $SessionStates = @{
            Active = 'Active'
            Connected = 'Conn'
            ConnectQuery = 'ConnQ'
            Shadow = 'Shadow'
            Listen = 'Listen'
            Disconnected = 'Disc'
            Idle = 'Idle'
            Down = 'Down'
            Initializing = 'Init'
        }

        # Skip unreachable hosts
        $ReachableHosts = $ComputerName | ? { Test-Connection $_ -Quiet -Count 1 }

        Write-Verbose "Found [$($Reachable.Count)/$($ComputerName.Count)] hosts"
    }

    process {
        foreach ($Computer in $ReachableHosts) {
            # Query host for remote sessions, skipping the first (header) line

            # TODO: Start-Process punts the output for some reason
            # https://stackoverflow.com/questions/8761888/capturing-standard-out-and-error-with-start-process

            $Output = qwinsta /server:$Computer | select -Skip 1

            Write-Verbose "Found [$($Output.Count)] sessions on [$Computer]"

            # Extract session data from each line of output
            foreach ($Line in $Output) {
                # Whether to output the object after any filtering. Using a flag like this should be
                # more performant (and slightly more idiomatic) than adding all sessions to an array
                # outside of the loop and *then* filtering
                $Include = $true

                # Convert fixed-width fields into CSV format. Note the leading space (thus 2 spaces
                # minimum) and that each line can potentially have *multiple* blank columns (thus 19
                # characters maximum)
                $Session = $Line -replace '\s{2,19}', ',' | ConvertFrom-Csv -Header 'SessionName', 'UserName', 'Id', 'State', 'Type', 'Device'

                # Convert state value from shorthand to expanded/pretty value
                $ExpandedState = $SessionStates.GetEnumerator().where({ $_.Value -eq $Session.State }).Name

                if ($Include) {
                    # Build the output object
                    [pscustomobject] @{
                        ComputerName = $Computer
                        SessionName = $Session.SessionName
                        UserName = $Session.UserName
                        SessionId = $Session.Id
                        State = $ExpandedState
                        Type = $Session.Type
                        Device = $Session.Device
                    }
                }
            }
        }
    }
}

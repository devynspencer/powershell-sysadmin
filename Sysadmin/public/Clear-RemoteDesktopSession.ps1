function Clear-RemoteDesktopSession {
    param (
        [Parameter(Mandatory)]
        $ComputerName,

        [Alias('SamAccountName', 'User')]
        $UserName = $env:USERNAME
    )

    process {
        foreach ($Server in $ComputerName) {
            Write-Host -ForegroundColor Magenta "Clearing remote desktop sessions on [$Server] for user [$UserName]..."

            Invoke-Command -ComputerName $Server {
                $ErrorActionPreference = 'Stop'

                try {
                    # Find all sessions matching the specified username
                    $Sessions = quser | where { $_ -match $Using:UserName }

                    # Parse the session IDs from the output
                    $SessionIds = ($Sessions -split ' +')[2]

                    Write-Host -ForegroundColor Magenta "Found [$($SessionIds.Count)] sessions for user [$Using:UserName]`n$Sessions"

                    # Loop through each session ID and pass each to the logoff command
                    foreach ($Id in $SessionIds) {
                        Write-Host -ForegroundColor Magenta "Logging off session id [$Id]..."
                        logoff $Id
                    }
                }

                catch {
                    Write-Error $_.Exception.Message
                }
            }
        }
    }
}

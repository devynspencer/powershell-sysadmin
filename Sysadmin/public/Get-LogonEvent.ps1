# TODO: Consider merging with Get-LogonFailureEvent (maybe adding a EventType or similar param with a handful of useful event types)

function Get-LogonEvent {
    Param (
        $Identity,

        [string]
        $Server = (Get-ADDomain).PDCEmulator,

        [datetime]
        $StartTime = (Get-Date).AddDays(-3),

        [datetime]
        $EndTime
    )

    begin {
        $LogonType = @{
            '2' = 'Interactive'
            '3' = 'Network'
            '4' = 'Batch'
            '5' = 'Service'
            '7' = 'Unlock'
            '8' = 'NetworkClearText'
            '9' = 'NewCredentials'
            '10' = 'RemoteInteractive'
            '11' = 'CachedInteractive'
        }

        $EventFilter = @{
            LogName = 'Security'
            Id = 4624
        }

        if ($PSBoundParameters.ContainsKey('StartTime')) {
            $EventFilter.StartTime = $StartTime
        }

        if ($PSBoundParameters.ContainsKey('EndTime')) {
            $EventFilter.EndTime = $EndTime
        }

        $Events = Get-WinEvent -ComputerName $Server -FilterHashtable $EventFilter
    }

    process {
        if ($PSBoundParameters.ContainsKey('Identity')) {
            $User = Get-ADUser $Identity
            $Events = $Events | ? { $_.Properties[5].Value -eq $User.SamAccountName }
        }

        foreach ($Event in $Events) {
            [pscustomobject] @{
                Server = $Server.ToLower()
                TargetAccount = $Event.properties.Value[5].ToLower()
                UserDomain = $Event.properties.Value[6].ToLower()
                LogonType = $LogonType."$($Event.properties.Value[8])"
                CallingComputer = $Event.Properties.Value[11].ToLower()
                IPAddress = $Event.Properties.Value[19]
                TimeCreated = $Event.TimeCreated
            }
        }
    }
}

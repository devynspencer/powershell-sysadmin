function Get-AccountLockoutEvent {
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
        $EventFilter = @{
            LogName = 'Security'
            Id = 4740
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
            $Events = $Events | ? { $_.Properties[0].Value -eq $Identity }
        }

        foreach ($Event in $Events) {
            [pscustomobject] @{
                Server = $Server.ToLower()
                TargetAccount = $Event.properties.Value[0].ToLower()
                CallingComputer = $Event.Properties.Value[1].ToLower()
                TimeCreated = $Event.TimeCreated
            }
        }
    }
}

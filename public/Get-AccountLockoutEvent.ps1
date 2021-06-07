<#
    .SYNOPSIS
        Get account lockout events from the PDC emulator.

    .PARAMETER Days
        Number of days of event logs to include.

    .EXAMPLE
        Get-AccountLockoutEvent

    .EXAMPLE
        Get-AccountLockoutEvent -Days 7
#>

function Get-AccountLockoutEvent {
    [CmdletBinding()]
    param (
        $Days = 3
    )

    $FilterParameters = @{
        LogName = 'Security'
        Id = 4740
        StartTime = (Get-Date).AddDays(-$Days)
    }

    $PDCEmulator = (Get-ADDomain).PDCEmulator
    $LockoutEvents = Get-WinEvent -ComputerName $PDCEmulator -FilterHashtable $FilterParameters

    foreach ($Event in $LockoutEvents) {
        [pscustomobject] @{
            AccountName = $Event.properties[0].value
            CallerName = $Event.properties[1].value
            AccountSid = $Event.properties[2].value.value
            DomainController = $Event.properties[4].value
            Domain = $Event.properties[5].value
        }
    }
}

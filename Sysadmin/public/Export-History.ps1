function Export-History {
    param (
        # Output the results to the console, in addition to copying to the clipboard
        [switch]
        $PassThru

        # TODO: Add switch to toggle unique entries only (currently always unique)

        # TODO: Add switch to toggle output to clipboard only (currently always outputs to clipboard, with an option for pass-thru)
    )

    $History = Get-History | select StartExecutionTime, @{n = 'DurationSeconds'; e = { ($_.Duration.TotalSeconds.ToString('0.00') -as [string]).PadLeft(10, ' ') } }, CommandLine

    # TODO: StartExecutionTime isn't easily predictable here with multiple of the same CommandLine, but I'm unsure
    # how to reconcile that when only grabbing the first entry
    # Using group as a way to get unique entries with multiple properties (select -Unique only works on one property)
    $UniqueHistory = $History | group CommandLine | % { $_.Group | select -First 1 } | sort StartExecutionTime

    if ($PassThru) {
        $UniqueHistory
    }

    $UniqueHistory | ConvertTo-Html -Fragment | Set-Clipboard

    Write-Verbose "Copied [$($UniqueHistory.Count)] entries to clipboard"
}

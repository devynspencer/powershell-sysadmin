. "$PSScriptRoot\New-Shortcut.ps1"

<#
.SYNOPSIS
    Create shortcuts for all print shares on a server and copy them to a location.

.PARAMETER Server
    Print server to create shortcuts for.

.PARAMETER Destination
    Path to copy staged shortcuts to.

.PARAMETER Path
    Path to a staging directory to create shortcuts in.

.EXAMPLE
    Sync-PrintShortcut -Server PRINTSERVER01 -Destination "\\example.com\Printers\Site01"
    Create shortcuts for all print shares served by PRINTSERVER01, and copy them to "\\example.com\Printers\Site01"

.NOTES
    Staging directory is a preference. There's no technical requirement for staging the shortcuts
    first. Future iterations could see this removed.
#>
function Sync-PrintShortcut {
    param (
        # Print server to create shortcuts for.
        [Parameter(Mandatory)]
        $Server,

        # Path to copy shortcuts to.
        [Parameter(Mandatory)]
        $Destination,

        # TODO: Consider removing staging directory or making it optional.
        # Path to staging directory to create shortcuts in.
        $Path = "$env:TEMP",

        # Shortcuts will not be copied to destination share.
        [switch]
        $StageOnly

        # TODO: Filter by printer name or other criteria
    )

    $Printers = Get-Printer -ComputerName $Server | ? { $_.Shared -and $_.ShareName }

    # Create a staging directory for the shortcuts (if none exists)
    $StagingPath = "$Path\PrintShortcuts\$Server"

    if (!(Test-Path -Path $StagingPath)) {
        New-Item -ItemType Directory -Path $StagingPath -Force
        Write-Host -ForegroundColor Cyan "Creating staging directory [$StagingPath]"
    }

    Write-Host -ForegroundColor Cyan "Creating shortcuts for printers on $Server"
    Write-Host -ForegroundColor Cyan "[$($Printers.Count)] printers found!"
    Write-Host -ForegroundColor DarkCyan "Using directory [$StagingPath] to stage shortcuts"

    foreach ($Printer in $Printers) {
        $TargetPath = "\\$Server\$($Printer.Name)"
        $ShortcutFilePath = Join-Path -Path $StagingPath -ChildPath "$($Printer.ShareName).lnk"

        Write-Host -ForegroundColor Cyan "Creating shortcut for [$($Printer.Name)] at [$ShortcutFilePath]"
        Write-Host -ForegroundColor DarkCyan "Current target is [$TargetPath]"

        # Create the shortcut
        $ShortcutParams = @{
            ShortcutPath = $ShortcutFilePath
            TargetPath = 'C:\Windows\System32\rundll32.exe'
            Arguments = 'printui.dll,PrintUIEntry', '/y', '/in', '/q', '/n', "$TargetPath"
            Description = "Connect to $($Printer.Name) on $Server"
        }

        New-Shortcut @ShortcutParams -Verbose

        # Copy the shortcut to the specified location
        if (!$StageOnly) {
            Write-Host -ForegroundColor Cyan "Copying shortcuts from [$StagingPath] to [$Destination]"
            Copy-Item -Path $ShortcutFilePath -Destination $Destination -Force
        }
    }
}

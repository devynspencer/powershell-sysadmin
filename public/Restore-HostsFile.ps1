<#
    .SYNOPSIS
        Restore the system hosts file from a backup.

    .PARAMETER BackupFilePath
        File path to backup file to restore from.

    .PARAMETER FilePath
        File path to system hosts file. Defaults to 'C:\Windows\System32\drivers\etc\hosts'.

    .EXAMPLE
        Restore-HostsFile

    .EXAMPLE
        Restore-HostsFile -BackupFilePath 'C:\temp\hosts.bak'
#>

function Restore-HostsFile {
    [CmdletBinding()]
    param (
        # TODO: use environment vars to determine system32 path, only allowing user to specify backup filename
        $BackupFilePath = 'C:\Windows\System32\drivers\etc\hosts.bak',

        # TODO: does this even make sense as a param?
        $FilePath = 'C:\Windows\System32\drivers\etc\hosts'
    )

    # TODO: add validation for old (or move into separate function)
    # TODO: handle missing files

    if (Test-Path -Path $BackupFilePath) {
        Write-Verbose "removing original hosts file: $FilePath"
        Remove-Item -Path $FilePath -Force

        Write-Verbose "restoring hosts file from: $BackupFilePath"
        Move-Item -Path $BackupFilePath -Destination $FilePath
    }
}

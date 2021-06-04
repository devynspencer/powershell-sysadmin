. "$PSScriptRoot\..\private\Import-ConfigurationData.ps1"
. "$PSScriptRoot\New-Shortcut.ps1"

<#
    .SYNOPSIS
        Populate a share with shortcuts to each shared printer on a print server.

    .DESCRIPTION
        Populate a share with shortcuts to each shared printer on a print server. Useful for distributed sharing of printers.

    .PARAMETER DataFilePath
        Path to JSON file containing infrastructure configuration data.

    .PARAMETER ExcludeName
        Do not create shortcuts for printers with specific names.

    .PARAMETER PrintShareRoot
        DFS namespace or file share to store the print shortcuts on.

    .PARAMETER CreateDirectory
        Create directories under the PrintShareRoot automatically, based on server site name from configuration data.

    .EXAMPLE
        Set-PrintShortcutShareContent -DataFilePath ./configs/print_servers.json
#>

function Set-PrintShortcutShareContent {
    param (
        $DataFilePath,

        [string[]]
        $ExcludeName = @(
            "Send To OneNote 2016"
            "Microsoft XPS Document Writer"
            "Microsoft Print to PDF"
        ),

        [Parameter(Mandatory)]
        $PrintShareRootPath,

        [switch]
        $CreateDirectory
    )

    $ConfigurationData = Import-ConfigurationData -FilePath $DataFilePath

    $PrintServers = $ConfigurationData.servers.where({ "print" -in $_.roles })

    foreach ($PrintServer in $PrintServers) {
        $AllPrinters = Get-Printer -ComputerName $PrintServer.hostname
        $Printers = $AllPrinters.where({ $_.Name -notin $ExcludeName -and $_.ShareName })

        foreach ($Printer in $Printers) {
            $PrintShareSourcePath = "\\$($PrintServer.hostname)\$($Printer.ShareName)"
            $PrintShareDestination = "$PrintShareRootPath\$($PrintServer.Site)\$($Printer.Name).lnk"

            if ($CreateDirectory) {
                New-Item -ItemType Directory -Path (Split-Path -Path $PrintShareDestination) -EA 0 | Out-Null
            }

            $Shortcut = New-Shortcut -TargetPath $PrintShareSourcePath -Destination $PrintShareDestination
        }
    }
}
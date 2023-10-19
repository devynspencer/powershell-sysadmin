function New-Shortcut {
    [CmdletBinding()]
    Param (
        # Target executable or location the shortcut will refer to
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $TargetPath,

        # File path of the created shortcut
        $ShortcutPath = (Join-Path -Path $env:USERPROFILE -ChildPath 'New Shortcut.lnk'),

        # Array of arguments to pass to the target executable.
        [string[]]
        $Arguments,

        # Accepts string or array. Ex: 'CTRL+SHIFT+F', Ex: @('CTRL','SHIFT','F')
        [string[]]
        $Keybind,

        # Path of working directory to specify in shortcut properties.
        $WorkingDirectory,

        # Description to specify in shortcut properties.
        $Description,

        # Icon file to use for shortcut.
        $IconLocation,

        # Window style to specify in shortcut properties.
        [ValidateSet('Default', 'Maximized', 'Minimized')]
        $WindowStyle = 'Default',

        # Run the shortcut with elevated credentials
        [switch]
        $Elevated
    )

    # Resolve window style
    switch ($WindowStyle) {
        'Default' {
            $Style = 1
            break
        }

        'Maximized' {
            $Style = 3
            break
        }

        'Minimized' {
            $Style = 7
        }
    }

    $WshShell = New-Object -ComObject WScript.Shell

    # Create a new shortcut
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $TargetPath
    $Shortcut.WindowStyle = $Style

    # Handle optional arguments
    if ($PSBoundParameters.ContainsKey('Arguments')) {
        $Shortcut.Arguments = $Arguments -join ' '
    }

    if ($PSBoundParameters.ContainsKey('Keybind')) {
        $Shortcut.Hotkey = ($Keybind -join '+').ToUpperInvariant()
    }

    if ($PSBoundParameters.ContainsKey('IconLocation')) {
        $Shortcut.IconLocation = $IconLocation
    }

    if ($PSBoundParameters.ContainsKey('Description')) {
        $Shortcut.Description = $Description
    }

    if ($PSBoundParameters.ContainsKey('WorkingDirectory')) {
        $Shortcut.WorkingDirectory = $WorkingDirectory
    }

    # Save shortcut properties
    $Shortcut.Save()

    Write-Host -ForegroundColor DarkCyan 'Configuring shortcut to run with elevated credentials'
    if ($Elevated) {
        # Read the shortcut file as byte array, set elevated byte to ON
        [byte[]] $Bytes = [System.IO.File]::ReadAllBytes($ShortcutPath)
        $Bytes[21] = $Bytes[21] -bor 0x20
        [System.IO.File]::WriteAllBytes($ShortcutPath, $Bytes)
    }

    # Clean up COM objects
    Write-Host -ForegroundColor DarkCyan 'Performing cleanup tasks'
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Shortcut) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($WshShell) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}

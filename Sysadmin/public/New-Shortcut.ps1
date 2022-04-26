<#
    .SYNOPSIS
        Create a shortcut.

    .PARAMETER FilePath
        Path to the file to create a shortcut to, i.e. 'C:\Program Files\Microsoft VS Code\Code.exe'.

    .PARAMETER Destination
        Path to create the shortcut at, i.e. 'C:\Users\foo\Desktop\code.lnk'

    .PARAMETER IconFilePath
        Path to the icon file to add to the shortcut.

    .PARAMETER Arguments
        Arguments, specified as a string, to pass to the shortcut target, i.e. '--disable-extensions' for the above would end up running the vscode binary without extensions: 'C:\Program Files\Microsoft VS Code\Code.exe --disable-extensions'

    .EXAMPLE
        New-Shortcut -FilePath 'C:\Users\public\foo.lnk' -TargetPath 'C:\Program Files\bar.exe' -Arguments '-DoSomething'
#>

function New-Shortcut {
    param (
        [Parameter(Mandatory)]
        [Alias('SourceFilePath', 'SourceSharePath')]
        $TargetPath,

        [Parameter(Mandatory)]
        [ValidatePattern('.*\.lnk')]
        $Destination,

        [ValidatePattern('.*\.ico')]
        $IconFilePath,

        $Arguments
    )

    $WscriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WscriptShell.CreateShortcut($Destination)
    $Shortcut.TargetPath = $TargetPath

    if ($PSBoundParameters.ContainsKey('IconFilePath')) {
        $Shortcut.IconLocation = $IconFilePath
    }

    if ($PSBoundParameters.ContainsKey('Arguments')) {
        $Shortcut.Arguments = $Arguments
    }

    $Shortcut.Save()
}
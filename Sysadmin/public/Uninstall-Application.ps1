function Uninstall-Application {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param (
        # Application name to uninstall, wildcards encouraged
        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string[]]
        $Name,

        # Publisher name to filter applications by, wildcards encouraged
        [Parameter(Mandatory, ParameterSetName = 'ByPublisher')]
        [string[]]
        $Publisher,

        [Parameter(Mandatory)]
        [ValidateSet('32-bit', '64-bit')]
        [string[]]
        $Architecture
    )

    $InstallData = switch ($Architecture) {
        '64-bit' {
            Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
        }

        '32-bit' {
            Get-ItemProperty 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
        }
    }

    $Applications = switch ($PSCmdlet.ParameterSetName) {
        'ByName' {
            foreach ($AppName in $Name) {
                $InstallData.where({ $_.DisplayName -like "$AppName" })
            }
        }

        'ByPublisher' {
            foreach ($PublisherName in $Publisher) {
                $InstallData.where({ $_.Publisher -like "$PublisherName" })
            }
        }
    }

    Write-Verbose "Found [$($Applications.Count)] applications matching query"

    foreach ($App in $Applications) {
        Write-Verbose ('Uninstalling software [{0}] version [1]' -f $App.DisplayName, $App.DisplayVersion)

        $UninstallParams = @{
            FilePath = 'msiexec.exe'
            NoNewWindow = $true
            Wait = $true
            ArgumentList = @(
                '/x'
                $App.PSChildName
            )
        }

        Start-Process @UninstallParams
    }
}

@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'Sysadmin.psm1'

    # Version number of this module.
    ModuleVersion = '0.0.0'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID = '55c496d2-670e-4716-9b1b-0ba0449c947d'

    # Author of this module
    Author = 'Devyn Spencer'

    # Company or vendor of this module
    CompanyName = ''

    # Copyright statement for this module
    Copyright = '(c) 2021 Devyn Spencer. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'PowerShell module focused on automating system administration tasks and encouraging standards-driven management.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '7.2.3'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'New-Shortcut'
        'Sync-PrintShortcut'
        'Get-AccountLockoutEvent'
        'Get-InstallProperty'
        'Get-DiskUsage'
        'Find-InactiveAccount'
        'Find-HomeDirectoryOrphan'
        'New-Shortcut'
        'Set-PrintShortcutShareContent'
        'Restore-HostsFile'
        'Uninstall-Application'
        'Get-LogonEvent'
        'Get-LogonFailureEvent'
        'Get-AccountLockoutEvent'
        'Get-RemoteSession'
        'Close-RemoteSession'
        'Enable-RemoteRPC'
        'Repair-LocalAdministrator'
        'Skip-Unreachable'
        'Get-OrgUser'
        'Get-UserMembership'
        'Get-OrgFileShare'
        'Repair-OrgFileShareAcl'
        'New-OrgFileShareGroup'
        'Clear-AclOrphanEntry'
        'Repair-OrgUserDirectoryAcl'
        'Test-OrgUserDirectoryAcl'
        'Resolve-OrgFileShareGroup'
        'Get-MsiData'
        'Select-MsiLogContent'
        'Measure-OrgServerCost'
        'Clear-RemoteDesktopSession'
        'Export-History'
        'Get-OrgDfsnShare'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # DSC resources to export from this module
    DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('sysadmin', 'print-management', 'share-management', 'dfs')

            # A URL to the license for this module.
            LicenseUri = 'https://raw.githubusercontent.com/devynspencer/powershell-sysadmin/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/devynspencer/powershell-sysadmin'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = 'https://raw.githubusercontent.com/devynspencer/powershell-sysadmin/main/README.md'
        }
    }

    # HelpInfo URI of this module
    HelpInfoURI = 'https://raw.githubusercontent.com/devynspencer/powershell-sysadmin/main/README.md'

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
}

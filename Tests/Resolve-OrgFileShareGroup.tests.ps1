BeforeAll {
    # TODO: Is this necessary? Otherwise we see a warning about the module being imported multiple times
    Remove-Module Sysadmin

    Import-Module "$PSScriptRoot\..\Sysadmin\Sysadmin.psd1" -Force

    # Mock Test-Path to prevent parameters that validate paths from failing
    Mock -ModuleName Sysadmin -CommandName Test-Path -MockWith { $true }
}

Describe 'Resolve-OrgFileShareGroup' {

    Context 'when the path is a filesystem path' {

        It 'resolves the group name for a DFS path' {
            $Path = '\\example.com\Files\Business Services\Marketing'

            Resolve-OrgFileShareGroup -Path $Path | Should -Be 'FS - Business Services Marketing'
        }

        It 'resolves the group name for a filesystem path' {
            $Path = 'C:\Users\Public\Documents'

            Resolve-OrgFileShareGroup -Path $Path | Should -Be 'FS - Public Documents'
        }
    }

    Context 'when the access type is specified' {

        It 'resolves the correct group name for a DFS path' {
            $Path = '\\example.com\Files\Business Services\Marketing'

            Resolve-OrgFileShareGroup -Path $Path -AccessType 'Modify' | Should -Be 'FS - Business Services Marketing'
            Resolve-OrgFileShareGroup -Path $Path -AccessType 'Read' | Should -Be 'FS - Business Services Marketing (Read)'
        }

        It 'resolves the correct group name for a filesystem path' {
            $Path = 'C:\Users\Public\Documents'

            Resolve-OrgFileShareGroup -Path $Path -AccessType 'Modify' | Should -Be 'FS - Public Documents'
            Resolve-OrgFileShareGroup -Path $Path -AccessType 'Read' | Should -Be 'FS - Public Documents (Read)'
        }
    }

    Context 'when paths specified via pipeline input' {

        It 'resolves the group name for a DFS path' {
            $Path = '\\example.com\Files\Business Services\Marketing'

            $Path | Resolve-OrgFileShareGroup | Should -Be 'FS - Business Services Marketing'
        }

        It 'resolves the group name for a filesystem path' {
            $Path = 'C:\Users\Public\Documents'

            $Path | Resolve-OrgFileShareGroup | Should -Be 'FS - Public Documents'
        }
    }
}

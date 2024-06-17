BeforeAll {
    Remove-Module Sysadmin -Force

    Import-Module "$PSScriptRoot\..\Sysadmin\Sysadmin.psd1" -Force

    Mock -ModuleName Sysadmin -CommandName Test-Path -MockWith { $true }

    # TODO: Mock Get-Acl, using ParameterFilter to mock different results (an assumed bad ACL versus a good ACL)
    Mock -ModuleName Sysadmin -CommandName Get-Acl -ParameterFilter { $Path -eq '\\example.com\Files\Business Unit\Bad Share' } -MockWith { throw 'Not mocked yet' }
    Mock -ModuleName Sysadmin -CommandName Get-Acl -ParameterFilter { $Path -eq '\\example.com\Files\Business Unit\Good Share' } -MockWith { throw 'Not mocked yet' }
}

Describe 'Test-OrgFileShareAcl' {

    Context 'when the ACL is correct' {

        It 'returns true' {
            $Path = '\\example.com\Files\Business Unit\Good Share'

            Test-OrgFileShareAcl -Path $Path | Should -Be $true
        }
    }

    Context 'when the ACL is incorrect' {

        It 'returns false' {
            $Path = '\\example.com\Files\Business Unit\Bad Share'

            Test-OrgFileShareAcl -Path $Path | Should -Be $false
        }
    }
}

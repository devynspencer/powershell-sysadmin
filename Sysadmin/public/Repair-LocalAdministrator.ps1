function Repair-LocalAdministrator {
    param (
        # Host(s) to operate on
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]
        $ComputerName
    )

    process {
        foreach ($Computer in $ComputerName) {
            $InvokeParams = @{
                ComputerName = $Computer
                HideComputername = $true
                ErrorAction = 'SilentlyContinue'
            }

            Invoke-Command @InvokeParams {
                # Get-LocalUser doesn't want to output a useful set of properties by default
                $Properties = 'Name', 'Enabled', 'AccountExpires', 'PasswordExpires'

                # Using the Microsoft.PowerShell.LocalAccounts module instead of net user or similar
                $LocalAdminParams = @{
                    Name = 'Administrator'
                }

                $OriginalState = Get-LocalUser @LocalAdminParams | select $Properties

                # Maintain idempotency, only update account when necessary
                if (!$OriginalState.Enabled) {
                    Enable-LocalUser @LocalAdminParams
                }

                if ($OriginalState.AccountExpires) {
                    Set-LocalUser @LocalAdminParams -AccountNeverExpires
                }

                if ($OriginalState.PasswordExpires) {
                    Set-LocalUser @LocalAdminParams -PasswordNeverExpires
                }
            }
        }
    }
}

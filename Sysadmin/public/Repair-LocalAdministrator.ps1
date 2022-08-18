function Repair-LocalAdministrator {
    param (
        # Host(s) to operate on
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]
        $ComputerName,

        [switch]
        $PassThru
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

                $UpdatedProperties = @()

                # Using the Microsoft.PowerShell.LocalAccounts module instead of net user or similar
                $LocalAdminParams = @{
                    Name = 'Administrator'
                }

                $OriginalState = Get-LocalUser @LocalAdminParams | select $Properties

                # Maintain idempotency, only update account when necessary
                if (!$OriginalState.Enabled) {
                    Enable-LocalUser @LocalAdminParams
                    $UpdatedProperties += 'Enabled'
                }

                if ($OriginalState.AccountExpires) {
                    Set-LocalUser @LocalAdminParams -AccountNeverExpires
                    $UpdatedProperties += 'AccountExpires'
                }

                if ($OriginalState.PasswordExpires) {
                    Set-LocalUser @LocalAdminParams -PasswordNeverExpires
                    $UpdatedProperties += 'PasswordExpires'
                }

                # Determine if changes were made
                $CurrentState = Get-LocalUser @LocalAdminParams | select $Properties

                # Format output object
                if ($using:PassThru) {
                    [pscustomobject] @{
                        ComputerName = $using:Computer
                        OriginalState = $OriginalState
                        CurrentState = $CurrentState
                        UpdatedProperties = $UpdatedProperties
                    }
                }
            }
        }
    }
}

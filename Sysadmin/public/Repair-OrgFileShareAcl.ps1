. "$PSScriptRoot\Get-OrgFileShare.ps1"

function Repair-OrgFileShareAcl {
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ByPath')]
        [string[]]
        $Path
    )

    process {
        foreach ($SharePath in $Path) {
            $ShareInfo = Get-OrgFileShare -Path $SharePath

            if (!$ShareInfo.GroupAdded) {
                Write-Verbose "Share [$($ShareInfo.Name)] missing group [$($ShareInfo.GroupName)]"

                # TODO: Refactor to use Start-Process in same window
                icacls $ShareInfo.Path /grant:r "$($ShareInfo.GroupName)`:(OI)(CI)(M)"
            }
        }
    }
}

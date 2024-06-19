function Select-MsiLogContent {
    param (
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        $Path,

        [ValidateSet('Property')]
        $ContentType = 'Property'
    )

    $LogContent = Get-Content -Path $Path

    switch ($ContentType) {
        'Property' {
            $SelectParams = @{
                CaseSensitive = $true
                Pattern = '^Property\(\w\):\s+([A-Z_]+\s+=\s+.*)'
            }

            foreach ($Match in ($LogContent | Select-String @SelectParams).Matches) {
                [pscustomobject] @{
                    Match = $Match.Groups[1].Value
                    Line = $Match.Groups[0].Value
                }
            }
        }
    }
}

<#
    .SYNOPSIS
        Import infrastructure data from json files.

    .DESCRIPTION
        Import infrastructure data from json files. Not using psd1 files to support
        interoperability between non-PowerShell tooling.

#>

function Import-ConfigurationData {
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]
        $FilePath
    )

    process {
        foreach ($ConfigurationFile in $FilePath) {
            Get-Content -Path $FilePath -Raw | ConvertFrom-Json
        }
    }
}
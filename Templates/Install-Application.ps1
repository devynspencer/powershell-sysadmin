[CmdletBinding()]
param (
    # Name of the application being installed. Used to identify output and logs
    $Application = 'Application Name',

    # Path to the installation executable (msiexec.exe, setup.exe, etc.)
    $FilePath = 'Setup.exe',

    # Arguments to pass to the installation executable
    $AgumentList = @( '/qn'),

    # Directory to store installation logs in
    $LogPath = "$env:SystemDrive\temp\Logs\Deployment"
)

$Context = $MyInvocation.MyCommand.Name
$Application = $Application -replace ' ', '-'

# Create log directory if it doesn't exist
if (!(Test-Path -Path $LogPath)) {
    $null = New-Item -Path $LogPath -ItemType Directory -Force
}

# Setup logging for both testing and deployment
$WriteParams = @{
    ForegroundColor = 'Magenta'
}

$LogParams = @{
    Path = Join-Path -Path $LogPath -ChildPath "$Application-$(Get-Date -Format FileDateTime).log"
    PassThru = $true
}

Add-Content @LogParams "[$Context] Starting installation of [$Application]" | Write-Host @WriteParams
Add-Content @LogParams "[$Context] Script called with [$($PSBoundParameters.Count)] params: $(ConvertTo-Json -Compress $PSBoundParameters)" | Write-Host @WriteParams
Add-Content @LogParams "[$Context] Logging to [$($LogParams.Path)]" | Write-Host @WriteParams

# Run the installer, using -Wait and .WaitForExit() due to the installer not exiting properly
$StartParams = @{
    FilePath = $FilePath
    ArgumentList = $ArgumentList
    RedirectStandardOutput = 'output.txt'
    RedirectStandardError = 'error.txt'
    Wait = $true
    NoNewWindow = $true
    Verbose = $true
    PassThru = $true
}

# Track execution start time
$StartTime = Get-Date

Add-Content @LogParams "[$Context] Running installer [$FilePath] with arguments [$($ArgumentList -join ' ')]" | Write-Host @WriteParams
Add-Content @LogParams "[$Context] Starting process at [$StartTime]" | Write-Host @WriteParams

# Start the installation executable and (really) wait for it to finish
$Process = Start-Process @StartParams
$Process.WaitForExit()

Add-Content @LogParams "[$Context] Start-Process finished with exit code [$($Process.ExitCode)]" | Write-Host @WriteParams
Add-Content @LogParams "[$Context] Total execution time: [$([Math]::Round((New-TimeSpan -Start $StartTime).TotalMinutes, 2)) minutes]" | Write-Host @WriteParams

# Copy standard output/error to logs
foreach ($StreamLog in @('output.txt', 'error.txt')) {
    if (!(Test-Path -Path $StreamLog)) {
        Add-Content @LogParams "[$Context] $StreamLog does not exist" | Write-Host @WriteParams
        continue
    }

    $Content = Get-Content -Path $StreamLog

    Add-Content @LogParams "[$Context] $StreamLog has [$($Content.Count)] lines" | Write-Host @WriteParams
    Add-Content @LogParams "[$Context] Copying [$StreamLog] to [$($LogParams.Path)]" | Write-Host @WriteParams

    # Append log name to each line
    $Content | % { "[$($_.PSChildName)] $($_)" } | Add-Content @LogParams | Write-Host @WriteParams

    # Remove the temporary log file
    Add-Content @LogParams "[$Context] Removing temporary log [$StreamLog]" | Write-Host @WriteParams
    $null = Remove-Item -Path $StreamLog -Force -ErrorAction SilentlyContinue
}

# TODO: Add switch parameter to avoid closing out of console window (i.e. when testing a deployment locally)
# Ensure correct exit code is sent to SCCM
[System.Environment]::Exit($Process.ExitCode)

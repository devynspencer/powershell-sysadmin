# Templates

Overview of the templates used in this project, and how to use them.

- TODO: Document how to deploy installation script templates to a new SCCM application deployment.

## `Install-Application.bat`

Batch script to install the application. Any arguments should be specified directly after -FilePath.

### Without parameters:

```batch
powershell.exe -NoProfile -ExecutionPolicy Bypass -NoLogo -File .\Install-Application.ps1
```

### With parameters (Untested).

Don't include the carets (^) in the actual script, they are used to indicate line continuation in batch files:

```batch
powershell.exe -NoProfile -ExecutionPolicy Bypass -NoLogo -File .\Install-Application.ps1 ^
 -FilePath "C:\Path\To\Installer.msi" ^
 -Arguments "/qn", "/foo"
```

## `Install-Application.ps1`

PowerShell script to install the application and log to a standard location.

### Viewing Install Log

```powershell
$LatestLog = Get-ChildItem -Path "C:\temp\Logs\Deployment\*.log" `
    | sort LastWriteTime -Descending | Select-Object -First 1

Get-Content -Path $LatestLog.FullName | more
```

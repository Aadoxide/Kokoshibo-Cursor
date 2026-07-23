$ErrorActionPreference = "Continue"

$self = $PID
$processes = Get-Process | Where-Object {
  $_.Id -ne $self -and (
    $_.ProcessName -eq "Moon Breathing Cursor" -or
    $_.Path -like "*Moon Breathing Cursor.exe"
  )
}

foreach ($process in $processes) {
  Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
}

$restoreScript = Join-Path $PSScriptRoot "restore-windows-cursor.ps1"
if (Test-Path $restoreScript) {
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $restoreScript
} else {
  Write-Warning "Could not find restore-windows-cursor.ps1 next to this script."
}

Write-Host "Moon Breathing Cursor stopped and Windows cursor restore was requested."

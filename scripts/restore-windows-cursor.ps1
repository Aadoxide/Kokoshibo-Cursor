$ErrorActionPreference = "Stop"

Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class CursorTools {
  [DllImport("user32.dll", SetLastError = true)]
  public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, IntPtr pvParam, uint fWinIni);
}
"@

$SPI_SETCURSORS = 0x0057
$SPIF_UPDATEINIFILE = 0x01
$SPIF_SENDCHANGE = 0x02

if (-not [CursorTools]::SystemParametersInfo($SPI_SETCURSORS, 0, [IntPtr]::Zero, $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE)) {
  throw "SystemParametersInfo failed while restoring cursors."
}

Write-Host "Windows cursors restored."

$ErrorActionPreference = "Stop"

Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class CursorTools {
  [DllImport("user32.dll")]
  public static extern IntPtr CreateCursor(
    IntPtr hInst,
    int xHotSpot,
    int yHotSpot,
    int nWidth,
    int nHeight,
    byte[] pvANDPlane,
    byte[] pvXORPlane
  );

  [DllImport("user32.dll", SetLastError = true)]
  public static extern bool SetSystemCursor(IntPtr hcur, uint id);
}
"@

$cursorIds = @(
  32512, # OCR_NORMAL
  32513, # OCR_IBEAM
  32514, # OCR_WAIT
  32515, # OCR_CROSS
  32516, # OCR_UP
  32640, # OCR_SIZE
  32641, # OCR_ICON
  32642, # OCR_SIZENWSE
  32643, # OCR_SIZENESW
  32644, # OCR_SIZEWE
  32645, # OCR_SIZENS
  32646, # OCR_SIZEALL
  32648, # OCR_NO
  32649, # OCR_HAND
  32650, # OCR_APPSTARTING
  32651, # OCR_HELP
  32671, # OCR_PIN
  32672  # OCR_PERSON
)

$width = 32
$height = 32
$maskBytes = [int](($width * $height) / 8)
$andMask = New-Object byte[] $maskBytes
$xorMask = New-Object byte[] $maskBytes

for ($i = 0; $i -lt $andMask.Length; $i++) {
  $andMask[$i] = 0xFF
}

foreach ($cursorId in $cursorIds) {
  $cursor = [CursorTools]::CreateCursor([IntPtr]::Zero, 0, 0, $width, $height, $andMask, $xorMask)
  if ($cursor -eq [IntPtr]::Zero) {
    throw "CreateCursor failed for cursor id $cursorId"
  }

  if (-not [CursorTools]::SetSystemCursor($cursor, [uint32]$cursorId)) {
    throw "SetSystemCursor failed for cursor id $cursorId"
  }
}

Write-Host "Windows cursors are hidden. Run npm run restore-cursor to restore them."

$ErrorActionPreference = "Stop"

Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class MouseButtonTools {
  [DllImport("user32.dll")]
  public static extern short GetAsyncKeyState(int vKey);
}
"@

$VK_LBUTTON = 0x01
$wasDown = $false

while ($true) {
  $isDown = ([MouseButtonTools]::GetAsyncKeyState($VK_LBUTTON) -band 0x8000) -ne 0

  if ($isDown -ne $wasDown) {
    if ($isDown) {
      Write-Output '{"button":"left","state":"down"}'
    } else {
      Write-Output '{"button":"left","state":"up"}'
    }

    [Console]::Out.Flush()
    $wasDown = $isDown
  }

  Start-Sleep -Milliseconds 8
}

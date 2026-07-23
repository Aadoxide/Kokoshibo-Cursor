$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$distApp = Join-Path $root "dist\win-unpacked"
$releaseDir = Join-Path $root "release"
$zipPath = Join-Path $releaseDir "Moon-Breathing-Cursor-win-x64-v1.0.0.zip"

if (-not (Test-Path $distApp)) {
  throw "Missing packaged app at $distApp. Run npm run build:win first."
}

if (-not (Test-Path $releaseDir)) {
  New-Item -ItemType Directory -Path $releaseDir | Out-Null
}

if (Test-Path $zipPath) {
  Remove-Item -LiteralPath $zipPath -Force
}

Compress-Archive -Path (Join-Path $distApp "*") -DestinationPath $zipPath -CompressionLevel Optimal

Write-Host "Created release asset:"
Write-Host $zipPath

param([Parameter(Mandatory=$true)][int]$GameProcessId,
    [Parameter(Mandatory=$true)][string]$Directory,[int]$Seconds=45)
$ErrorActionPreference='Stop'
$game=Get-Process -Id $GameProcessId
if ($game.ProcessName -ne 'gzdoom' -or $game.MainWindowHandle -eq 0) { throw 'Expected an existing GZDoom window.' }
$outputPath=[IO.Path]::GetFullPath($Directory)
if (!(Test-Path -LiteralPath $outputPath)) { New-Item -ItemType Directory -Path $outputPath | Out-Null }
Add-Type -AssemblyName System.Drawing
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class CA334Window {
  [StructLayout(LayoutKind.Sequential)] public struct Rect { public int Left,Top,Right,Bottom; }
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr handle,out Rect rect);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr handle);
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr handle,IntPtr dc,uint flags);
}
'@
$null=[CA334Window]::SetForegroundWindow($game.MainWindowHandle)
$watch=[Diagnostics.Stopwatch]::StartNew();$count=0
while ($watch.Elapsed.TotalSeconds -lt $Seconds -and !$game.HasExited) {
    $rect=New-Object CA334Window+Rect
    if (![CA334Window]::GetWindowRect($game.MainWindowHandle,[ref]$rect)) { break }
    $width=$rect.Right-$rect.Left;$height=$rect.Bottom-$rect.Top
    $bitmap=New-Object Drawing.Bitmap($width,$height)
    $graphics=[Drawing.Graphics]::FromImage($bitmap)
    try {
        if ([CA334Window]::GetForegroundWindow() -eq $game.MainWindowHandle) {
            $graphics.CopyFromScreen($rect.Left,$rect.Top,0,0,$bitmap.Size)
        } else {
            $dc=$graphics.GetHdc()
            try { $ok=[CA334Window]::PrintWindow($game.MainWindowHandle,$dc,2) }
            finally { $graphics.ReleaseHdc($dc) }
            if (!$ok) { throw 'Target window capture unavailable; no desktop fallback.' }
        }
        $bitmap.Save((Join-Path $outputPath ('frame-{0:D5}-{1:D7}.png' -f $count,[int]$watch.ElapsedMilliseconds)),[Drawing.Imaging.ImageFormat]::Png)
    } finally { $graphics.Dispose();$bitmap.Dispose() }
    $count++;Start-Sleep -Milliseconds 100
}
@{pid=$GameProcessId;frames=$count;elapsed_seconds=$watch.Elapsed.TotalSeconds;method='Foreground target rectangle or target-only PrintWindow; visual QA only'} |
    ConvertTo-Json | Set-Content -LiteralPath (Join-Path $outputPath 'capture.json') -Encoding utf8

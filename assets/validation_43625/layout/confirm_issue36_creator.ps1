param([int]$TargetPid)
Add-Type @'
using System;
using System.Runtime.InteropServices;
using System.Text;
public class Confirm36 {
 public delegate bool EnumProc(IntPtr h,IntPtr p);
 [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc f,IntPtr p);
 [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h,out uint p);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] public static extern int GetClassName(IntPtr h,StringBuilder s,int n);
 [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr h,uint m,IntPtr w,IntPtr l);
}
'@
$creatorWindows=[Collections.Generic.List[IntPtr]]::new()
[Confirm36]::EnumWindows({param($h,$p)
 $owner36=[uint32]0;[void][Confirm36]::GetWindowThreadProcessId($h,[ref]$owner36)
 if($owner36 -eq $TargetPid){
  $class36=[Text.StringBuilder]::new(256);[void][Confirm36]::GetClassName($h,$class36,256)
  if($class36.ToString() -eq 'MainWindow'){$creatorWindows.Add($h)}
 };return $true
},[IntPtr]::Zero) | Out-Null
if($creatorWindows.Count -ne 1){throw 'Expected exactly one MainWindow owned by the test process'}
$h36=$creatorWindows[0]
[void][Confirm36]::PostMessage($h36,0x100,[IntPtr]13,[IntPtr]0x1c0001)
Start-Sleep -Milliseconds 100
[void][Confirm36]::PostMessage($h36,0x101,[IntPtr]13,[IntPtr]3223060481)
Write-Output "Creator Enter dispatched to owned window $h36"

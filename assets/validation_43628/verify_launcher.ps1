param([Parameter(Mandatory=$true)][string]$OutputDirectory)
$ErrorActionPreference = 'Stop'
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
if (Test-Path -LiteralPath $OutputDirectory) { throw 'Use a new test directory.' }
$Fixture = Join-Path $OutputDirectory 'Portable game (spaces)'
[IO.Directory]::CreateDirectory($Fixture) | Out-Null
$Source = Join-Path $PSScriptRoot '../playtest/launch_playtest.ps1'
$Launcher = Join-Path $Fixture 'launch_playtest.ps1'
Copy-Item -LiteralPath $Source -Destination $Launcher
[IO.File]::WriteAllText((Join-Path $Fixture 'DOOM2.WAD'), 'Local test stub; not an IWAD.')
[IO.File]::WriteAllText((Join-Path $Fixture 'caelum_argenteum_dev.pk3'), 'Local test stub; not a game package.')
$Stub = @'
using System;
using System.IO;
public class LauncherProbe {
    public static int Main(string[] args) {
        string root = AppDomain.CurrentDomain.BaseDirectory;
        File.WriteAllLines(Path.Combine(root, "arguments.txt"), args);
        File.WriteAllText(Path.Combine(root, "working_directory.txt"), Environment.CurrentDirectory);
        return File.Exists(Path.Combine(root, "fail.flag")) ? 17 : 0;
    }
}
'@
Add-Type -TypeDefinition $Stub -OutputAssembly (Join-Path $Fixture 'gzdoom.exe') -OutputType ConsoleApplication
$Cases = @(
    @{Name='automatic adjacent discovery'; Engine=$null; Iwad=$null; Exit=0},
    @{Name='relative filenames from another directory'; Engine='gzdoom.exe'; Iwad='DOOM2.WAD'; Exit=0},
    @{Name='quoted paths with surrounding spaces'; Engine=('  "'+(Join-Path $Fixture 'gzdoom.exe')+'"  '); Iwad=('  "'+(Join-Path $Fixture 'DOOM2.WAD')+'"  '); Exit=0},
    @{Name='containing folders'; Engine=$Fixture; Iwad=$Fixture; Exit=0},
    @{Name='missing engine diagnostic'; Engine='absent.exe'; Iwad=$null; Exit=1},
    @{Name='engine failure exit propagation'; Engine=$null; Iwad=$null; Exit=17}
)
$Results = @()
Push-Location -LiteralPath $OutputDirectory
try {
    foreach ($Case in $Cases) {
        if ($Case.Exit -eq 17) { [IO.File]::WriteAllText((Join-Path $Fixture 'fail.flag'), 'fail') }
        $Invocation = "& '" + $Launcher.Replace("'", "''") + "'"
        foreach ($Key in @('Engine','Iwad')) {
            if ($null -ne $Case[$Key]) { $Invocation += " -$Key '" + $Case[$Key].Replace("'", "''") + "'" }
        }
        $Invocation += "`nexit " + '$LASTEXITCODE'
        $Wrapper = Join-Path $OutputDirectory ('case'+$Results.Count+'.ps1')
        [IO.File]::WriteAllText($Wrapper, $Invocation)
        $Output = & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $Wrapper 2>&1
        $ActualExit = $LASTEXITCODE
        if ($ActualExit -ne $Case.Exit) { throw "$($Case.Name): unexpected exit $ActualExit. $Output" }
        if ($Case.Exit -ne 1) {
            $ActualArguments = [IO.File]::ReadAllLines((Join-Path $Fixture 'arguments.txt'))
            $ExpectedArguments = @('-iwad',(Join-Path $Fixture 'DOOM2.WAD'),'-file',(Join-Path $Fixture 'caelum_argenteum_dev.pk3'),'-config',(Join-Path $Fixture 'user/gzdoom.ini'),'-savedir',(Join-Path $Fixture 'user/saves'),'-noautoload')
            if (($ActualArguments -join "`n") -ne ($ExpectedArguments -join "`n")) { throw "$($Case.Name): unexpected engine arguments" }
            if ([IO.File]::ReadAllText((Join-Path $Fixture 'working_directory.txt')) -ne $Fixture) { throw 'Wrong engine working directory' }
        } elseif (($Output -join "`n") -notlike '*Could not find gzdoom.exe*absent.exe*') {
            throw 'Missing attempted path in error message'
        }
        $Results += [ordered]@{case=$Case.Name; result='PASS'; exit_code=$ActualExit}
    }
} finally {
    Pop-Location
}
$Results | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $OutputDirectory 'RESULTS.json') -Encoding UTF8
$Results | ConvertTo-Json -Depth 4

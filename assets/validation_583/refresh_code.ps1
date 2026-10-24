# Refresh changed source entries for compile iterations; final delivery uses build_dev.ps1.
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $repo
if(Get-Process gzdoom -ErrorAction SilentlyContinue){throw 'Close the native process before refreshing its package.'}
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$package=Join-Path $repo 'build/issue410/current/caelum_argenteum_dev.pk3'
$history=Join-Path $repo "build/issue410/refreshed-sources.json"
$previous=if(Test-Path -LiteralPath $history){@(Get-Content -Raw -LiteralPath $history | ConvertFrom-Json)}else{@()}
$names=@(@("src/MAPINFO","src/ZSCRIPT")+$previous+@(git -c core.safecrlf=false diff --name-only -- src)+@(git ls-files --others --exclude-standard -- src) | Sort-Object -Unique)
$names | ConvertTo-Json | Set-Content -Encoding utf8 -LiteralPath $history
$archive=[IO.Compression.ZipFile]::Open($package,[IO.Compression.ZipArchiveMode]::Update)
try {
    foreach($name in $names){
        if(!$name.StartsWith('src/')){continue}
        $entryName=$name.Substring(4)
        $entry=$archive.GetEntry($entryName)
        if($entry){$entry.Delete()}
        $null=[IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive,(Join-Path $repo $name),$entryName,[IO.Compression.CompressionLevel]::Optimal)
    }
} finally {$archive.Dispose()}
Write-Output "Refreshed $($names.Count) source entries for native compilation."

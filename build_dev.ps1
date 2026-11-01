param(
    [string]$Source = "src",
    [string]$Destination = "build/caelum_argenteum_dev.pk3",
    [switch]$LegacyMap01,
    [switch]$LegacyTarotMaps,
    [switch]$LegacyTarotExamples,
    [switch]$LegacyMap02,
    [switch]$LegacyMap02Revision4,
    [switch]$LegacyMap06,
    [switch]$LegacyMap06Siege,
    [switch]$LegacyMap06NorthCity,
    [switch]$LegacyMap06SouthCity,
    [switch]$LegacyMap06Furnished
)

$ErrorActionPreference = "Stop"
if ($LegacyTarotExamples -and ($LegacyTarotMaps -or $LegacyMap01)) {
    throw 'Select one mansion baseline: -LegacyTarotExamples, -LegacyTarotMaps or -LegacyMap01.'
}
if ($LegacyMap02 -and $LegacyMap02Revision4) {
    throw 'Select only one MAP02 compatibility revision: -LegacyMap02 or -LegacyMap02Revision4.'
}
if (([int]$LegacyMap06.IsPresent + [int]$LegacyMap06Siege.IsPresent + [int]$LegacyMap06NorthCity.IsPresent + [int]$LegacyMap06SouthCity.IsPresent + [int]$LegacyMap06Furnished.IsPresent) -gt 1) {
    throw 'Select only one MAP06 compatibility revision: -LegacyMap06, -LegacyMap06Siege, -LegacyMap06NorthCity, -LegacyMap06SouthCity or -LegacyMap06Furnished.'
}

$ProjectRoot = $PSScriptRoot
$SourcePath = [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot $Source))
$DestinationPath = [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot $Destination))

# An old WAD alone cannot restore the former map catalogue and hub identities.
if (($LegacyMap06 -or $LegacyMap06Siege -or $LegacyMap06NorthCity -or $LegacyMap06SouthCity -or $LegacyMap06Furnished) -and
    -not (Test-Path -LiteralPath (Join-Path $SourcePath 'maps/MAP06.wad'))) {
    throw 'MAP06 compatibility switches require the pre-5.4.29 checkout (b9fd71ce). Restore that full checkout/package for old saves; the current city is MAP03. Existing output was not changed.'
}

if (-not (Test-Path -LiteralPath $SourcePath -PathType Container)) {
    throw "Source directory does not exist: $SourcePath"
}

# Refuse stale generated dialogue or localization locations before packaging.
& python (Join-Path $ProjectRoot 'build_dialogue_index.py') --root $ProjectRoot --source $SourcePath check
if ($LASTEXITCODE -ne 0) { throw 'Dialogue/localization validation failed. Run python build_dialogue_index.py build.' }

$Files = @(Get-ChildItem -LiteralPath $SourcePath -Recurse -File | Sort-Object FullName)
if ($Files.Count -eq 0) {
    throw "Source directory contains no files: $SourcePath"
}

# Keep the established package name so GZDoom can restore existing saves.
# Compatibility replaces only selected map lumps; runtime code stays current.
$LegacyTarotBytes = @{}
if ($LegacyTarotMaps) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $TarotData = Join-Path $ProjectRoot 'assets/tarot_justice'
    $TarotManifest = Get-Content -LiteralPath (Join-Path $TarotData 'MAPS.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    $TarotArchivePath = Join-Path $TarotData 'legacy_5133.zip'
    if ((Get-FileHash -LiteralPath $TarotArchivePath -Algorithm SHA256).Hash -ine $TarotManifest.archive_sha256) {
        throw 'Pre-Justice map archive checksum mismatch; existing output was not changed.'
    }
    $TarotArchive = [IO.Compression.ZipFile]::OpenRead($TarotArchivePath)
    try {
        foreach ($Map in $TarotManifest.maps) {
            $MapEntry = $TarotArchive.GetEntry($Map.file)
            if ($null -eq $MapEntry) { throw "Missing pre-Justice map: $($Map.file)" }
            $MapStream = $MapEntry.Open()
            $MapBuffer = [IO.MemoryStream]::new()
            try { $MapStream.CopyTo($MapBuffer); $MapBytes = $MapBuffer.ToArray() }
            finally { $MapStream.Dispose(); $MapBuffer.Dispose() }
            $MapHasher = [Security.Cryptography.SHA256]::Create()
            try { $MapHash = [BitConverter]::ToString($MapHasher.ComputeHash($MapBytes)).Replace('-', '') }
            finally { $MapHasher.Dispose() }
            if ($MapHash -ine $Map.legacy_sha256) { throw "Pre-Justice map checksum mismatch: $($Map.file)" }
            $LegacyTarotBytes["maps/$($Map.file)"] = $MapBytes
        }
    }
    finally { $TarotArchive.Dispose() }
}
$LegacyMap01Bytes = $null
if ($LegacyTarotExamples) {
    $ExampleDirectory = Join-Path $ProjectRoot 'assets/tarot_examples'
    $ExampleBaseline = Get-Content -LiteralPath (Join-Path $ExampleDirectory 'BASELINE.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    $ExampleMapPath = Join-Path $ExampleDirectory $ExampleBaseline.baseline_file
    if ((Get-FileHash -LiteralPath $ExampleMapPath -Algorithm SHA256).Hash -ine $ExampleBaseline.baseline_sha256) {
        throw 'Pre-example mansion checksum mismatch; existing output was not changed.'
    }
    $LegacyMap01Bytes = [IO.File]::ReadAllBytes($ExampleMapPath)
}
if ($LegacyMap01) {
    $LegacyMansionPath = Join-Path $ProjectRoot 'assets/map01_mansion/legacy_581/MAP01.wad'
    if ((Get-FileHash -LiteralPath $LegacyMansionPath -Algorithm SHA256).Hash -ne '866A25A3ADAD62A742F3A1E65FA9C029852450B99E372B63CAF57321B15F408A') {
        throw 'Legacy MAP01 checksum mismatch; refusing to replace the existing PK3.'
    }
    $LegacyMap01Bytes = [IO.File]::ReadAllBytes($LegacyMansionPath)
}
$LegacyMap02Bytes = $null
if ($LegacyMap02 -or $LegacyMap02Revision4) {
    if ($LegacyMap02Revision4) {
        $LegacyMap02Path = Join-Path $ProjectRoot "assets/map02_maze/legacy_5432/MAP02.wad"
        $LegacyMap02Hash = "6337BC73CA32BB9DB9936052AC341D34ACE75B3C66858DFC4EAA0E6833CE55F1"
    }
    else {
        $LegacyMap02Path = Join-Path $ProjectRoot "assets/map02_maze/legacy_4364/MAP02.wad"
        $LegacyMap02Hash = "9095BDA962F5410BA869B3780DFF2A58C11FF0A011E35D451A43052B851406D2"
    }
    if (-not (Test-Path -LiteralPath $LegacyMap02Path -PathType Leaf)) {
        throw "Legacy MAP02 source is missing: $LegacyMap02Path"
    }
    $LegacyMap02Bytes = [System.IO.File]::ReadAllBytes($LegacyMap02Path)
    $Hasher = [System.Security.Cryptography.SHA256]::Create()
    try {
        $ActualHash = [BitConverter]::ToString($Hasher.ComputeHash($LegacyMap02Bytes)).Replace('-', '')
    }
    finally {
        $Hasher.Dispose()
    }
    if ($ActualHash -ne $LegacyMap02Hash) {
        throw "Legacy MAP02 checksum mismatch; refusing to replace the existing PK3."
    }
}

$LegacyMap06Bytes = $null
if ($LegacyMap06) {
    $LegacyPortPath = Join-Path $ProjectRoot 'assets/map06_port/legacy_43626/MAP06.wad'
    if ((Get-FileHash -LiteralPath $LegacyPortPath -Algorithm SHA256).Hash -ne '5AE44D61F8D29342C16C6EF8A98308BE98B92C02643E585C14CB986106D453B8') {
        throw 'Legacy MAP06 checksum mismatch; refusing to replace the existing PK3.'
    }
    $LegacyMap06Bytes = [IO.File]::ReadAllBytes($LegacyPortPath)
}
if ($LegacyMap06Siege) {
    $LegacyPortPath = Join-Path $ProjectRoot 'assets/map06_port/legacy_4378/MAP06.wad'
    if ((Get-FileHash -LiteralPath $LegacyPortPath -Algorithm SHA256).Hash -ne 'D7D6F79C3197DB8FD4958CC35C07794DF8DFF1399197BAA7655F8420ADBBB51A') {
        throw 'Legacy siege MAP06 checksum mismatch; refusing to replace the existing PK3.'
    }
    $LegacyMap06Bytes = [IO.File]::ReadAllBytes($LegacyPortPath)
}
if ($LegacyMap06NorthCity) {
    $LegacyPortPath = Join-Path $ProjectRoot 'assets/map06_port/legacy_4379_north/MAP06.wad'
    if ((Get-FileHash -LiteralPath $LegacyPortPath -Algorithm SHA256).Hash -ne '8B88438A0905D0F42665C47E5793DFAA79FD2B824E810A987D1F4EEAE7E1FADF') {
        throw 'Legacy north-city MAP06 checksum mismatch; refusing to replace the existing PK3.'
    }
    $LegacyMap06Bytes = [IO.File]::ReadAllBytes($LegacyPortPath)
}

if ($LegacyMap06SouthCity) {
    $LegacyPortPath = Join-Path $ProjectRoot 'assets/map06_port/legacy_512/MAP06.wad'
    if ((Get-FileHash -LiteralPath $LegacyPortPath -Algorithm SHA256).Hash -ne '84F0C18FDB4BE7A91EFF146845F78DDA5082D5B0C9D996928F0652D7C6FC7EFD') {
        throw 'Legacy south-city MAP06 checksum mismatch; refusing to replace the existing PK3.'
    }
    $LegacyMap06Bytes = [IO.File]::ReadAllBytes($LegacyPortPath)
}

if ($LegacyMap06Furnished) {
    $LegacyPortPath = Join-Path $ProjectRoot 'assets/map06_port/legacy_5427/MAP06.wad'
    if ((Get-FileHash -LiteralPath $LegacyPortPath -Algorithm SHA256).Hash -ne '8D62EF32AD584ED43E21613BC216CDFAC4423469481EBA8CE594DA3E0B3ED26C') {
        throw 'Legacy furnished MAP06 checksum mismatch; refusing to replace the existing PK3.'
    }
    $LegacyMap06Bytes = [IO.File]::ReadAllBytes($LegacyPortPath)
}

foreach ($File in $Files) {
    if ($File.Length -eq 0) {
        throw "Empty files are not allowed in the PK3: $($File.FullName)"
    }

    if ($File.Extension -ieq ".png") {
        $Stream = [System.IO.File]::OpenRead($File.FullName)
        try {
            $Header = New-Object byte[] 24
            if ($Stream.Read($Header, 0, 24) -ne 24) {
                throw "Truncated PNG: $($File.FullName)"
            }

            $Signature = [byte[]](137, 80, 78, 71, 13, 10, 26, 10)
            for ($Index = 0; $Index -lt 8; $Index++) {
                if ($Header[$Index] -ne $Signature[$Index]) {
                    throw "Invalid PNG: $($File.FullName)"
                }
            }

            $Width = [System.Net.IPAddress]::NetworkToHostOrder(
                [BitConverter]::ToInt32($Header, 16)
            )
            $Height = [System.Net.IPAddress]::NetworkToHostOrder(
                [BitConverter]::ToInt32($Header, 20)
            )
            if ($Width -le 0 -or $Height -le 0) {
                throw "PNG has invalid dimensions: $($File.FullName)"
            }
        }
        finally {
            $Stream.Dispose()
        }
    }
}

$DestinationDirectory = Split-Path -Parent $DestinationPath
[System.IO.Directory]::CreateDirectory($DestinationDirectory) | Out-Null
$TemporaryPath = Join-Path $DestinationDirectory (
    [System.IO.Path]::GetRandomFileName() + ".pk3.tmp"
)

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

try {
    $OutputStream = [System.IO.File]::Open(
        $TemporaryPath,
        [System.IO.FileMode]::CreateNew,
        [System.IO.FileAccess]::ReadWrite,
        [System.IO.FileShare]::None
    )
    try {
        $Archive = [System.IO.Compression.ZipArchive]::new(
            $OutputStream,
            [System.IO.Compression.ZipArchiveMode]::Create,
            $true
        )
        try {
            $LegacyReplacementCount = 0
            $LegacyMansionReplacementCount = 0
            $LegacyPortReplacementCount = 0
            $LegacyTarotReplacementCount = 0
            foreach ($File in $Files) {
                $RelativePath = $File.FullName.Substring($SourcePath.Length).TrimStart(
                    [char[]]@('\', '/')
                )
                $EntryName = $RelativePath.Replace('\', '/')
                if ($LegacyTarotMaps -and $LegacyTarotBytes.ContainsKey($EntryName)) { $LegacyTarotReplacementCount++ }
                $Entry = $Archive.CreateEntry(
                    $EntryName,
                    [System.IO.Compression.CompressionLevel]::Optimal
                )
                $EntryStream = $Entry.Open()
                try {
                    if (($LegacyMap01 -or $LegacyTarotExamples) -and $EntryName -ieq 'maps/MAP01.wad') {
                        $EntryStream.Write($LegacyMap01Bytes, 0, $LegacyMap01Bytes.Length)
                        $LegacyMansionReplacementCount++
                    }
                    elseif (($LegacyMap02 -or $LegacyMap02Revision4) -and $EntryName -ieq "maps/MAP02.wad") {
                        $EntryStream.Write($LegacyMap02Bytes, 0, $LegacyMap02Bytes.Length)
                        $LegacyReplacementCount++
                    }
                    elseif (($LegacyMap06 -or $LegacyMap06Siege -or $LegacyMap06NorthCity -or $LegacyMap06SouthCity -or $LegacyMap06Furnished) -and $EntryName -ieq 'maps/MAP06.wad') {
                        $EntryStream.Write($LegacyMap06Bytes, 0, $LegacyMap06Bytes.Length)
                        $LegacyPortReplacementCount++
                    }
                    elseif ($LegacyTarotMaps -and $LegacyTarotBytes.ContainsKey($EntryName)) {
                        $MapBytes = $LegacyTarotBytes[$EntryName]
                        $EntryStream.Write($MapBytes, 0, $MapBytes.Length)
                    }
                    else {
                        $InputStream = [System.IO.File]::OpenRead($File.FullName)
                        try {
                            $InputStream.CopyTo($EntryStream)
                        }
                        finally {
                            $InputStream.Dispose()
                        }
                    }
                }
                finally {
                    $EntryStream.Dispose()
                }
            }
            if (($LegacyMap02 -or $LegacyMap02Revision4) -and $LegacyReplacementCount -ne 1) {
                throw "Legacy compatibility requires exactly one maps/MAP02.wad entry in the source."
            }
            if ($LegacyTarotMaps -and $LegacyTarotReplacementCount -ne $LegacyTarotBytes.Count) {
                throw 'Pre-Justice compatibility requires every preserved map in the package.'
            }
            if (($LegacyMap01 -or $LegacyTarotExamples) -and $LegacyMansionReplacementCount -ne 1) {
                throw 'Legacy compatibility requires exactly one maps/MAP01.wad entry in the source.'
            }
            if (($LegacyMap06 -or $LegacyMap06Siege -or $LegacyMap06NorthCity -or $LegacyMap06SouthCity -or $LegacyMap06Furnished) -and $LegacyPortReplacementCount -ne 1) {
                throw 'Legacy compatibility requires exactly one maps/MAP06.wad entry in the source.'
            }
        }
        finally {
            $Archive.Dispose()
        }
    }
    finally {
        $OutputStream.Dispose()
    }

    $CheckStream = [System.IO.File]::OpenRead($TemporaryPath)
    try {
        $CheckArchive = [System.IO.Compression.ZipArchive]::new(
            $CheckStream,
            [System.IO.Compression.ZipArchiveMode]::Read,
            $false
        )
        try {
            foreach ($Entry in $CheckArchive.Entries) {
                if ($Entry.FullName.EndsWith("/")) {
                    throw "PK3 contains a directory entry: $($Entry.FullName)"
                }
                if ($Entry.Length -eq 0) {
                    throw "PK3 contains an empty entry: $($Entry.FullName)"
                }
            }
        }
        finally {
            $CheckArchive.Dispose()
        }
    }
    finally {
        $CheckStream.Dispose()
    }

    # Atomic replacement: the previous PK3 remains available if the build fails.
    if (Test-Path -LiteralPath $DestinationPath) {
        [System.IO.File]::Replace($TemporaryPath, $DestinationPath, [NullString]::Value)
    } else {
        [System.IO.File]::Move($TemporaryPath, $DestinationPath)
    }
    Write-Host "PK3 created successfully: $DestinationPath"
    if ($LegacyTarotMaps) {
        Write-Host 'Justice compatibility: byte-identical pre-arena maps; newer arena effects are unavailable. Explicit older per-map switches take precedence.'
    } else {
        Write-Host 'Justice geometry: new campaigns. Pre-Justice visited-map saves require -LegacyTarotMaps.'
    }
    if ($LegacyTarotExamples) {
        Write-Host 'MAP01 layout: byte-identical Justice-era mansion before the Tarot example annex.'
    }
    elseif ($LegacyMap01) {
        Write-Host 'MAP01 layout: byte-identical pre-5.8.2 mansion for existing campaigns; connected deposits inactive.'
    }
    else {
        Write-Host 'MAP01 layout: follows the Justice mode above. Pre-5.8.2 mansion saves additionally need -LegacyMap01.'
    }
    if ($LegacyMap02Revision4) {
        Write-Host "MAP02 compatibility: exact pre-5.4.33 revision 4 for existing visited-map saves."
        Write-Host "The old western crusher defect remains in that geometry. Rebuild without -LegacyMap02Revision4 and start a fresh MAP02 to use the corrected panel."
    }
    elseif ($LegacyMap02) {
        Write-Host "MAP02 compatibility: original 4.36.4 layout retained for existing saves."
        Write-Host "New four-section MAP02 is not active in this build. Rebuild without -LegacyMap02 to restore it."
    }
    else {
        Write-Host "MAP02 layout: follows the Justice mode above. Older visited-map saves additionally need -LegacyMap02Revision4 (pre-5.4.33) or -LegacyMap02 (original 4.36.4)."
    }
    Write-Host "Files included: $($Files.Count)"
    if ($LegacyMap06) { Write-Host 'MAP06 layout: byte-identical 4.36.26 compatibility port; no new siege geometry.' }
    elseif ($LegacyMap06Siege) { Write-Host 'MAP06 layout: byte-identical 4.37.8 siege port for existing campaigns; expanded city inactive.' }
    elseif ($LegacyMap06NorthCity) { Write-Host 'MAP06 layout: byte-identical first 4.37.9 city with the northern siege.' }
    elseif ($LegacyMap06SouthCity) { Write-Host 'MAP06 layout: exact 5.1.2 southern city compatibility geometry.' }
    elseif ($LegacyMap06Furnished) { Write-Host 'MAP06 layout: exact pre-5.4.28 furnished city for existing campaigns; open geometry reduction inactive.' }
    else { Write-Host 'MAP03: original house footprints, private hub interiors and roof-height district sky; taller exterior sky. Start a fresh campaign; the old catalogue remains recoverable at b9fd71ce.' }
    Write-Host "Directory entries: 0"
}
finally {
    if (Test-Path -LiteralPath $TemporaryPath) {
        Remove-Item -LiteralPath $TemporaryPath -Force
    }
}

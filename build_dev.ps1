param(
    [string]$Source = "src",
    [string]$Destination = "build/caelum_argenteum_dev.pk3",
    [switch]$LegacyMap02
)

$ErrorActionPreference = "Stop"

$ProjectRoot = $PSScriptRoot
$SourcePath = [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot $Source))
$DestinationPath = [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot $Destination))

if (-not (Test-Path -LiteralPath $SourcePath -PathType Container)) {
    throw "Source directory does not exist: $SourcePath"
}

$Files = @(Get-ChildItem -LiteralPath $SourcePath -Recurse -File | Sort-Object FullName)
if ($Files.Count -eq 0) {
    throw "Source directory contains no files: $SourcePath"
}

# Keep the established package name so GZDoom can restore existing saves.
# Only the MAP02 lump changes; current code and all other maps stay current.
$LegacyMap02Bytes = $null
if ($LegacyMap02) {
    $LegacyMap02Path = Join-Path $ProjectRoot "assets/map02_maze/legacy_4364/MAP02.wad"
    $LegacyMap02Hash = "9095BDA962F5410BA869B3780DFF2A58C11FF0A011E35D451A43052B851406D2"
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
            foreach ($File in $Files) {
                $RelativePath = $File.FullName.Substring($SourcePath.Length).TrimStart(
                    [char[]]@('\', '/')
                )
                $EntryName = $RelativePath.Replace('\', '/')
                $Entry = $Archive.CreateEntry(
                    $EntryName,
                    [System.IO.Compression.CompressionLevel]::Optimal
                )
                $EntryStream = $Entry.Open()
                try {
                    if ($LegacyMap02 -and $EntryName -ieq "maps/MAP02.wad") {
                        $EntryStream.Write($LegacyMap02Bytes, 0, $LegacyMap02Bytes.Length)
                        $LegacyReplacementCount++
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
            if ($LegacyMap02 -and $LegacyReplacementCount -ne 1) {
                throw "Legacy compatibility requires exactly one maps/MAP02.wad entry in the source."
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
    if ($LegacyMap02) {
        Write-Host "MAP02 compatibility: original 4.36.4 layout retained for existing saves."
        Write-Host "New four-section MAP02 is not active in this build. Rebuild without -LegacyMap02 to restore it."
    }
    else {
        Write-Host "MAP02 layout: current source. Use -LegacyMap02 for saves that already visited the old maze."
    }
    Write-Host "Files included: $($Files.Count)"
    Write-Host "Directory entries: 0"
}
finally {
    if (Test-Path -LiteralPath $TemporaryPath) {
        Remove-Item -LiteralPath $TemporaryPath -Force
    }
}

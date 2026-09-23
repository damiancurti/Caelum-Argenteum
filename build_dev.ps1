param(
    [string]$Source = "src",
    [string]$Destination = "build/caelum_argenteum_dev.pk3"
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
                $InputStream = [System.IO.File]::OpenRead($File.FullName)
                try {
                    $InputStream.CopyTo($EntryStream)
                }
                finally {
                    $InputStream.Dispose()
                    $EntryStream.Dispose()
                }
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
    Write-Host "Files included: $($Files.Count)"
    Write-Host "Directory entries: 0"
}
finally {
    if (Test-Path -LiteralPath $TemporaryPath) {
        Remove-Item -LiteralPath $TemporaryPath -Force
    }
}

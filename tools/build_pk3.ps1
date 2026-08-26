param(
    [string]$Source = "src",
    [string]$Destination = "build/caelum_argenteum_dev.pk3"
)

$ErrorActionPreference = "Stop"

$ProjectRoot = (Get-Location).Path
$SourcePath = [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot $Source))
$DestinationPath = [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot $Destination))

if (-not (Test-Path -LiteralPath $SourcePath -PathType Container)) {
    throw "No existe la carpeta de fuentes: $SourcePath"
}

$Files = @(Get-ChildItem -LiteralPath $SourcePath -Recurse -File | Sort-Object FullName)
if ($Files.Count -eq 0) {
    throw "La carpeta de fuentes no contiene archivos: $SourcePath"
}

foreach ($File in $Files) {
    if ($File.Length -eq 0) {
        throw "Archivo vacío no permitido dentro del PK3: $($File.FullName)"
    }

    if ($File.Extension -ieq ".png") {
        $Stream = [System.IO.File]::OpenRead($File.FullName)
        try {
            $Header = New-Object byte[] 24
            if ($Stream.Read($Header, 0, 24) -ne 24) {
                throw "PNG incompleto: $($File.FullName)"
            }

            $Signature = [byte[]](137, 80, 78, 71, 13, 10, 26, 10)
            for ($Index = 0; $Index -lt 8; $Index++) {
                if ($Header[$Index] -ne $Signature[$Index]) {
                    throw "PNG inválido: $($File.FullName)"
                }
            }

            $Width = [System.Net.IPAddress]::NetworkToHostOrder(
                [BitConverter]::ToInt32($Header, 16)
            )
            $Height = [System.Net.IPAddress]::NetworkToHostOrder(
                [BitConverter]::ToInt32($Header, 20)
            )
            if ($Width -le 0 -or $Height -le 0) {
                throw "PNG con dimensiones inválidas: $($File.FullName)"
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
                    throw "El PK3 contiene una entrada de directorio: $($Entry.FullName)"
                }
                if ($Entry.Length -eq 0) {
                    throw "El PK3 contiene una entrada vacía: $($Entry.FullName)"
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

    if (Test-Path -LiteralPath $DestinationPath) {
        Remove-Item -LiteralPath $DestinationPath -Force
    }
    [System.IO.File]::Move($TemporaryPath, $DestinationPath)
    Write-Host "PK3 creado correctamente: $DestinationPath"
    Write-Host "Archivos incluidos: $($Files.Count)"
    Write-Host "Entradas de directorio: 0"
}
finally {
    if (Test-Path -LiteralPath $TemporaryPath) {
        Remove-Item -LiteralPath $TemporaryPath -Force
    }
}

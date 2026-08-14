# Stop immediately if PowerShell encounters an error.
$ErrorActionPreference = "Stop"

# $PSScriptRoot is the folder containing this PowerShell script.
$projectRoot = $PSScriptRoot
$sourceDirectory = Join-Path $projectRoot "src"
$buildDirectory = Join-Path $projectRoot "build"
$outputPk3 = Join-Path $buildDirectory "caelum_argenteum_dev.pk3"
$temporaryZip = Join-Path $buildDirectory "caelum_argenteum_dev.zip"

# Verify that the source folder exists before attempting to package it.
if (-not (Test-Path $sourceDirectory -PathType Container)) {
    throw "The source directory does not exist: $sourceDirectory"
}

# Create the build folder the first time the project is run.
New-Item -ItemType Directory -Path $buildDirectory -Force | Out-Null

# Remove only the previous generated development packages.
Remove-Item $outputPk3 -Force -ErrorAction SilentlyContinue
Remove-Item $temporaryZip -Force -ErrorAction SilentlyContinue

# PK3 files are ZIP archives with a different extension. Compress-Archive
# packages the contents of src, not the src folder itself.
Compress-Archive -Path (Join-Path $sourceDirectory "*") -DestinationPath $temporaryZip -CompressionLevel Optimal

# Rename the generated ZIP archive to the extension expected by GZDoom mods.
Move-Item $temporaryZip $outputPk3

Write-Host "Development PK3 created successfully:"
Write-Host $outputPk3


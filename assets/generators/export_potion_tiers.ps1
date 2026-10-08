param()
$ErrorActionPreference = 'Stop'
# Deterministic format export only; artwork is preserved ImageGen output.
Add-Type -AssemblyName System.Drawing
$repo = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$source = Join-Path $repo 'assets/art_source/potions_515'
$target = Join-Path $repo 'src/graphics/caelum/icons/potions'
$null = New-Item -ItemType Directory -Force -Path $target
foreach ($family in @('medikit','anima','energy')) {
    foreach ($size in @('medium','large')) {
        $name = $family + '_' + $size + '.png'
        $inputImage = [Drawing.Image]::FromFile((Join-Path $source $name))
        $outputImage = New-Object Drawing.Bitmap(128,128,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $canvas = [Drawing.Graphics]::FromImage($outputImage)
        try {
            $canvas.Clear([Drawing.Color]::Transparent)
            $canvas.CompositingMode = [Drawing.Drawing2D.CompositingMode]::SourceCopy
            $canvas.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $canvas.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $canvas.DrawImage($inputImage,(New-Object Drawing.Rectangle(0,0,128,128)),0,0,$inputImage.Width,$inputImage.Height,[Drawing.GraphicsUnit]::Pixel)
            $outputImage.Save((Join-Path $target $name),[Drawing.Imaging.ImageFormat]::Png)
        } finally { $canvas.Dispose(); $outputImage.Dispose(); $inputImage.Dispose() }
    }
}

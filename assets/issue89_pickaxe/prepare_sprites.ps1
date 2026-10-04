param([string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$source = [System.Drawing.Bitmap]::new((Join-Path $PSScriptRoot 'pickaxe_isolated.png'))
function Write-ScaledSprite([string]$Relative, [int]$Width, [int]$Height, [System.Drawing.Rectangle]$Destination) {
    $path = Join-Path $Root $Relative
    [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($path)) | Out-Null
    $bitmap = [System.Drawing.Bitmap]::new($Width, $Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.DrawImage($source, $Destination, [System.Drawing.Rectangle]::new(0,0,$source.Width,$source.Height), [System.Drawing.GraphicsUnit]::Pixel)
    $graphics.Dispose()
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()
}
# Asset-space placement only: artistic isolation was made with OpenAI imagegen.
# Original grip (500, 1200) maps to (216,160), matching the native shared hand rig.
Write-ScaledSprite 'src/sprites/caelum/pickaxe/pickaxe_body.png' 320 200 ([System.Drawing.Rectangle]::new(157,18,121,182))
Write-ScaledSprite 'src/graphics/caelum/icons/ca_pickaxe.png' 128 128 ([System.Drawing.Rectangle]::new(27,1,76,114))
$source.Dispose()

#requires -PSEdition Desktop
# Pin the Windows PowerShell / .NET Framework rasterizer for reproducible glyphs.
param([string]$ProjectRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent))
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$design = Get-Content -LiteralPath (Join-Path $ProjectRoot 'assets/map06_port/HOUSE_HUBS.json') -Encoding UTF8 -Raw | ConvertFrom-Json
$outDir = Join-Path $ProjectRoot 'src/graphics/caelum/shop_signs'
New-Item -ItemType Directory -Path $outDir -Force | Out-Null
$colors = @('#263D2E', '#532C24', '#253D43', '#30364C', '#3C3831', '#46334B', '#3D3431', '#2E3A42')
function ColorBrush([string]$color) { return [Drawing.SolidBrush]::new([Drawing.ColorTranslator]::FromHtml($color)) }
$cream = ColorBrush '#EEE0B5'
$wood = ColorBrush '#39291F'
$edge = [Drawing.Pen]::new([Drawing.ColorTranslator]::FromHtml('#C5A772'), 5)
$ink = [Drawing.Pen]::new([Drawing.ColorTranslator]::FromHtml('#EEE0B5'), 10)
$grain = [Drawing.Pen]::new([Drawing.Color]::FromArgb(28,230,207,160), 2)
$font = [Drawing.Font]::new('Georgia', 54, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$smallFont = [Drawing.Font]::new('Georgia', 43, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$format = [Drawing.StringFormat]::new()
$format.Alignment = [Drawing.StringAlignment]::Center
$format.LineAlignment = [Drawing.StringAlignment]::Center
for ($category=0; $category -lt $design.sign_categories.Count; $category++) {
    $canvas = [Drawing.Bitmap]::new(1024,256,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [Drawing.Graphics]::FromImage($canvas)
    $g.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.Clear([Drawing.Color]::Transparent)
    $g.FillRectangle($wood, 0, 0, 1024, 256)
    $paint = ColorBrush $colors[$category]
    $g.FillRectangle($paint, 12, 12, 1000, 232)
    for ($row=0; $row -lt 13; $row++) {
        $y = 20 + 17*$row
        $g.DrawBezier($grain, 18,$y, 280,($y+9), 740,($y-7), 1006,$y)
    }
    $g.DrawRectangle($edge, 22,22,980,212)
    $g.DrawLine($edge, 248,40,248,216)
    foreach($x in @(34,990)) { foreach($y in @(34,222)) { $g.FillEllipse($wood,$x-6,$y-6,12,12) } }
    # Original vector trade symbols: no external artwork or font files packaged.
    switch ($category) {
        0 {
            $g.DrawEllipse($ink,55,118,128,64)
            foreach($x in @(83,115,147)) { $g.DrawLine($ink,$x,129,$x-10,154) }
            $g.DrawRectangle($ink,153,64,38,54); $g.DrawRectangle($ink,162,44,20,20)
        }
        1 {
            $g.DrawLine($ink,66,190,172,62); $g.DrawLine($ink,76,144,121,180)
            $g.DrawLine($ink,66,168,49,188); $g.DrawLine($ink,49,188,65,202)
            $g.DrawLine($ink,172,62,172,89); $g.DrawLine($ink,172,62,146,69)
        }
        2 {
            $g.DrawLine($ink,55,177,196,78); $g.DrawLine($ink,66,191,110,160)
            $g.DrawLine($ink,55,177,66,191); $g.DrawLine($ink,99,145,124,161)
            $g.DrawRectangle($ink,143,151,25,53); $g.DrawArc($ink,143,135,25,32,180,180)
        }
        3 {
            $g.DrawEllipse($ink,73,101,106,105)
            $points=[Drawing.Point[]]@([Drawing.Point]::new(126,49),[Drawing.Point]::new(165,79),[Drawing.Point]::new(126,112),[Drawing.Point]::new(87,79))
            $g.DrawPolygon($ink,$points);$g.DrawLine($ink,87,79,165,79)
        }
        4 {
            $points=[Drawing.Point[]]@([Drawing.Point]::new(61,61),[Drawing.Point]::new(191,61),[Drawing.Point]::new(180,151),[Drawing.Point]::new(126,207),[Drawing.Point]::new(72,151))
            $g.DrawPolygon($ink,$points);$g.DrawLine($ink,126,68,126,188)
        }
        5 {
            $g.DrawLine($ink,82,202,164,73);$g.DrawEllipse($ink,145,46,39,39)
            $g.DrawLine($ink,93,55,93,89);$g.DrawLine($ink,76,72,110,72)
            $g.DrawLine($ink,185,139,185,165);$g.DrawLine($ink,172,152,198,152)
        }
        6 {
            $g.DrawRectangle($ink,51,65,73,130);$g.DrawRectangle($ink,124,65,73,130)
            foreach($y in @(94,119,144,169)) {$g.DrawLine($edge,66,$y,109,$y);$g.DrawLine($edge,139,$y,182,$y)}
            $g.DrawLine($ink,124,57,124,205)
        }
        7 {
            $points=[Drawing.Point[]]@([Drawing.Point]::new(98,52),[Drawing.Point]::new(64,73),[Drawing.Point]::new(43,143),[Drawing.Point]::new(70,154),[Drawing.Point]::new(89,107),[Drawing.Point]::new(80,204),[Drawing.Point]::new(170,204),[Drawing.Point]::new(161,107),[Drawing.Point]::new(180,154),[Drawing.Point]::new(207,143),[Drawing.Point]::new(186,73),[Drawing.Point]::new(152,52),[Drawing.Point]::new(125,86))
            $g.DrawPolygon($ink,$points);$g.DrawLine($ink,125,86,125,204)
        }
    }
    $label = $design.sign_labels[$category]
    $selectedFont = $font
    if ($category -eq 2) { $label="ARMAS Y`nMUNICIONES"; $selectedFont=$smallFont }
    $g.DrawString($label,$selectedFont,$cream,[Drawing.RectangleF]::new(266,37,724,182),$format)
    $canvas.Save((Join-Path $outDir ('CASG{0:D2}.png' -f $category)),[Drawing.Imaging.ImageFormat]::Png)
    $paint.Dispose();$g.Dispose();$canvas.Dispose()
}
$format.Dispose();$font.Dispose();$smallFont.Dispose();$grain.Dispose();$ink.Dispose();$edge.Dispose();$cream.Dispose();$wood.Dispose()
Write-Output 'Eight deterministic original trade-sign textures generated (Georgia raster outlines; font file not distributed).'

# Labelled review crops; native originals remain unchanged.
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$captures=@(Get-ChildItem -LiteralPath 'build/issue61_views' -Filter '*.png' | Sort-Object Name)
$font=New-Object Drawing.Font('Arial',10)
for($batch=0;$batch -lt 4;$batch++){
    $sheet=New-Object Drawing.Bitmap(1600,2208)
    $graphics=[Drawing.Graphics]::FromImage($sheet)
    $graphics.Clear([Drawing.Color]::FromArgb(21,21,21))
    for($i=0;$i -lt 32;$i++){
        $capture=$captures[$batch*32+$i]
        $source=[Drawing.Image]::FromFile($capture.FullName)
        $x=($i%4)*400;$y=[Math]::Floor($i/4)*276
        $target=New-Object Drawing.Rectangle($x,($y+23),400,253)
        $graphics.DrawImage($source,$target,360,80,1200,760,[Drawing.GraphicsUnit]::Pixel)
        $graphics.DrawString($capture.Name,$font,[Drawing.Brushes]::White,($x+8),($y+3))
        $source.Dispose()
    }
    $sheet.Save((Join-Path (Get-Location) "build/issue61_contact_$batch.png"),[Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose();$sheet.Dispose()
}
$font.Dispose()
Write-Output 'Four labelled contact sheets, 128 unchanged native originals.'

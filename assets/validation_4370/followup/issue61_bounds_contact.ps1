# Review all distant-ground native captures without modifying the originals.
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$sheet=New-Object Drawing.Bitmap(1440,882)
$graphics=[Drawing.Graphics]::FromImage($sheet)
$graphics.Clear([Drawing.Color]::Black)
$font=New-Object Drawing.Font('Arial',11)
for($i=0;$i -lt 9;$i++){
    $source=[Drawing.Image]::FromFile((Join-Path (Get-Location) "build/issue61_bound_$i.png"))
    $x=($i%3)*480;$y=[Math]::Floor($i/3)*294
    $target=New-Object Drawing.Rectangle($x,($y+24),480,270)
    $graphics.DrawImage($source,$target)
    $graphics.DrawString("Exterior view $i",$font,[Drawing.Brushes]::White,($x+8),($y+3))
    $source.Dispose()
}
$sheet.Save((Join-Path (Get-Location) 'build/issue61_bounds_contact.png'),[Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose();$sheet.Dispose();$font.Dispose()

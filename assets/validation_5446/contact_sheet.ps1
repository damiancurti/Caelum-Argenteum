param([Parameter(Mandatory=$true)][string]$Directory,[int]$Stride=4)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$frames=@(Get-ChildItem -LiteralPath $Directory -Filter 'frame-*.png' | Sort-Object Name)
$selected=@(for($i=0;$i -lt $frames.Count;$i+=$Stride){$frames[$i]})
$font=New-Object Drawing.Font('Consolas',9)
try {
    for($page=0;$page*40 -lt $selected.Count;$page++){
        $sheet=New-Object Drawing.Bitmap(1600,1000)
        $canvas=[Drawing.Graphics]::FromImage($sheet);$canvas.Clear([Drawing.Color]::Black)
        try {
            for($cell=0;$cell -lt 40 -and ($page*40+$cell) -lt $selected.Count;$cell++){
                $file=$selected[$page*40+$cell];$image=[Drawing.Image]::FromFile($file.FullName)
                $x=($cell%5)*320;$y=[int][Math]::Floor($cell/5)*125
                try { $canvas.DrawImage($image,$x,$y,320,105) } finally { $image.Dispose() }
                $canvas.DrawString($file.BaseName,$font,[Drawing.Brushes]::White,$x,$y+106)
            }
            $sheet.Save((Join-Path $Directory "sheet-$page.png"),[Drawing.Imaging.ImageFormat]::Png)
        } finally { $canvas.Dispose();$sheet.Dispose() }
    }
} finally { $font.Dispose() }

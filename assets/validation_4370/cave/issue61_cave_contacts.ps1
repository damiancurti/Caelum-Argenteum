$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
foreach($group in @('far','cave')){
    $names=if($group -eq 'far'){@('far_0','far_1','far_2','far_3','far_4','far_5','far_6','far_7')}else{@('approach','mouth','inside','bend','return','hill')}
    $columns=if($group -eq 'far'){4}else{3}
    $sheet=New-Object Drawing.Bitmap(($columns*480),588)
    $graphics=[Drawing.Graphics]::FromImage($sheet)
    $graphics.Clear([Drawing.Color]::Black)
    $font=New-Object Drawing.Font('Arial',11)
    for($i=0;$i -lt $names.Count;$i++){
        $source=[Drawing.Image]::FromFile((Join-Path (Get-Location) ('build/issue61_cave_'+$names[$i]+'.png')))
        $x=($i%$columns)*480;$y=[Math]::Floor($i/$columns)*294
        $target=New-Object Drawing.Rectangle($x,($y+24),480,270)
        $graphics.DrawImage($source,$target)
        $graphics.DrawString($names[$i],$font,[Drawing.Brushes]::White,($x+8),($y+3))
        $source.Dispose()
    }
    $sheet.Save((Join-Path (Get-Location) ('build/issue61_'+$group+'_contact.png')),[Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose();$sheet.Dispose();$font.Dispose()
}

param([string]$Runtime='final36b',[string]$Prefix='releaseb',[string]$VisualPrefix='releasec')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Push-Location $repo
try {
    python assets/validation_5836/prepare.py
    if($LASTEXITCODE -ne 0){throw 'Preparation failed'}
    foreach($case in @('catalogue','craft','trade','items','placement','sofaplace','studyseed','studyresume','studyhub','studyinput','studyinstall','studyupgrade','sofamigration','legacy','view6','view7','studygallery0','studygallery1')) {
        $map=if($case-in@('catalogue','craft','trade','items','view6','view7')){'CSUP410'}else{'MAP01'}
        $script=if($case-eq'sofamigration'){'sofaresume'}else{$case}
        $taskArguments=@('-NoProfile','-ExecutionPolicy','Bypass','-File','assets/validation_5836/run_native.ps1','-Label',"$Prefix-$case",'-Runtime',$Runtime,'-Script',$script,'-StartMap',$map,'-Checks')
        if($case-eq'studyresume'){$taskArguments+=@('-LoadGame','study-furniture.zds')}
        if($case-eq'studyupgrade'){$taskArguments+=@('-LoadGame','study-prior.zds')}
        if($case-eq'sofamigration'){$taskArguments+=@('-LoadGame','prior-sofa-supply.zds')}
        if($case-eq'legacy'){$taskArguments+=@('-LoadGame','reading-progress.zds')}
        if($case-in@('view6','view7','studygallery0','studygallery1')){$taskArguments+=@('-Language','es')}
        & powershell @taskArguments
        if($LASTEXITCODE -ne 0){throw "Failed: $case"}
    }
    foreach($kind in @(0,1)) {
        & powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5836/run_native.ps1 -Label "$VisualPrefix-visual$kind" -Runtime $Runtime -Script "visual$kind" -StartMap CSUP410 -Addon gallery.pk3 -Language es -Checks
        if($LASTEXITCODE -ne 0){throw "Failed: visual$kind"}
    }
} finally {Pop-Location}

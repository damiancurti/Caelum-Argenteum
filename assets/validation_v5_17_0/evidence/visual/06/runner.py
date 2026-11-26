"""Compare the accepted fixed model with separate native modules and save overrides.

This isolated art room does not change ordinary players, equipment or collision.
"""
from pathlib import Path
import argparse
import hashlib
import json
import re
import subprocess
import sys
import zipfile

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/validation_v5_16_3'))
from run_nahuelito_preview import wad
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['runtime','model','output']:parser.add_argument('--'+name,type=Path,required=True)
    parser.add_argument('--interactive',action='store_true',help='Open the review room and wait for the author to close it; no automatic acceptance.')
    args=parser.parse_args();runtime=args.runtime.resolve(strict=True);model=args.model.resolve(strict=True)
    if not (model/'preview.pk3').is_file():parser.error('--model must contain preview.pk3')
    count=subprocess.run(['powershell','-NoProfile','-Command','@(Get-Process gzdoom -ErrorAction SilentlyContinue).Count'],capture_output=True,text=True,check=True)
    if int(count.stdout.strip()):parser.error('Close existing GZDoom before the isolated preview.')
    out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    manifest=json.loads((model/'manifest.json').read_text(encoding='utf-8'))
    legacy=['Model CA458LegacyPreview','{','    Path "models/caelum/domingo"','    Model 0 "domingo.md3"','    Skin 0 "domingo_skin.png"','    Scale 1 1 1','    DontCullBackFaces']
    for index in range(manifest['frames']):legacy.append(f'    FrameIndex D3{index//26:02X} {chr(65+index%26)} 0 {index}')
    legacy.append('}')
    fixture=out/'fixture.pk3'
    with zipfile.ZipFile(fixture,'w') as package:
        for name,blob in {'maps/CA455V.wad':wad(224),'ZSCRIPT':b'version "4.14.2"\n'+Path(__file__).with_name('modular_preview.zs').read_bytes(),
            'MODELDEF':('\n'.join(legacy)+'\n').encode(),
            'MAPINFO':b'gameinfo { AddEventHandlers="CA458PreviewEvents" }\nmap CA455V "Modular character inspection" { sky1="CABASKY",0 nointermission }\n'}.items():
            package.writestr(zipfile.ZipInfo(name,(2026,11,13,0,0,0)),blob)
    (out/'session.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n')
    fresh='screenblocks 12; crosshair 0; con_notifytime 0; wait 140; netevent ca458_prepare; wait 20; screenshot legacy.png; netevent ca458_select 1; wait 20; screenshot modular.png; '
    fresh+='netevent ca458_module 5 0; netevent ca458_module 6 0; wait 20; screenshot unarmed.png; netevent ca458_restore; wait 20; screenshot restored.png; '
    fresh+='netevent ca458_animate; wait 11; netevent ca458_motion; screenshot walk.png; netevent ca458_freeze; '
    fresh+='netevent ca458_module 4 0; netevent ca458_module 6 0; wait 20; screenshot hidden.png; netevent ca458_verify; save modules; wait 20; quit\n'
    reload='screenblocks 12; crosshair 0; con_notifytime 0; wait 35; netevent ca458_verify; screenshot reloaded.png; netevent ca458_restore; wait 20; screenshot reload-restored.png; wait 20; quit\n'
    # Screenshot requests are rendered later; keep the next mutation behind a barrier.
    fresh=re.sub(r'(screenshot [^;]+;)',r'\1 wait 5;',fresh)
    reload=re.sub(r'(screenshot [^;]+;)',r'\1 wait 5;',reload)
    report={'issue':458,'scope':__doc__.strip(),'runtime_sha256':digest(runtime),'model_sha256':digest(model/'preview.pk3'),'fixture_sha256':digest(fixture),'runs':[]}
    if args.interactive:
        commands='wait 140; netevent ca458_prepare; wait 20; netevent ca458_select 1; '
        commands+='bind F1 "netevent ca458_select 0"; bind F2 "netevent ca458_select 1"; '
        commands+='bind F3 "netevent ca458_module 5 0; netevent ca458_module 6 0"; bind F4 "netevent ca458_restore"; '
        commands+='bind F5 "netevent ca458_module 4 0; netevent ca458_module 6 0"; bind F6 "netevent ca458_animate"; bind F7 "netevent ca458_freeze";\n'
        (out/'interactive.cfg').write_text(commands)
        print('F1 fixed / F2 modular / F3 remove sword+shield / F4 restore / F5 remove hair+shield / F6 walk / F7 freeze. Close GZDoom to finish review. No automatic acceptance.',flush=True)
        command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(runtime),str(model/'preview.pk3'),str(fixture),'-config',str(out/'session.ini'),'-savedir',str(out),'-window','+logfile',str(out/'interactive.log'),'+map','CA455V','+exec',str(out/'interactive.cfg')]
        subprocess.run(command,cwd=out,check=True)
        return
    for label,commands,entry in [('fresh',fresh,['+map','CA455V']),('reload',reload,['-loadgame','modules.zds'])]:
        (out/(label+'.cfg')).write_text(commands)
        command=[str(ENGINE),'-noautoload','-nomouse','-iwad',str(IWAD),'-file',str(runtime),str(model/'preview.pk3'),str(fixture),'-config',str(out/'session.ini'),'-savedir',str(out),'-window','-width','1280','-height','720','+logfile',str(out/(label+'.log')),*entry,'+exec',str(out/(label+'.cfg'))]
        startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
        with (out/(label+'-process.log')).open('wb') as stream:
            process=subprocess.Popen(command,cwd=out,stdout=stream,stderr=stream,startupinfo=startup)
            try:code=process.wait(timeout=120)
            except subprocess.TimeoutExpired:process.terminate();process.wait(timeout=10);code=process.returncode
        log=(out/(label+'.log')).read_text(errors='replace') if (out/(label+'.log')).exists() else ''
        errors=[line for line in log.splitlines() if any(token in line for token in ['Script error','Execution could not continue','VM execution aborted','Unknown command','Unable to load model','CA458 FAIL'])]
        passed=code==0 and not errors and 'CA458 COMPLETE failures=0' in log
        report['runs'].append({'phase':label,'exit_code':code,'passed':passed,'errors':errors,'checks':[line for line in log.splitlines() if line.startswith('CA458 ')]})
        report['captures']={path.name:digest(path) for path in sorted(out.glob('*.png'))}
        (out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
        print(json.dumps(report['runs'][-1]),flush=True)
        if not passed:raise SystemExit(1)
    captures=report['captures']
    report['visual_checks']={
        'fixed_matches_modular':captures['legacy.png']==captures['modular.png'],
        'weapon_shield_hide_visible':captures['modular.png']!=captures['unarmed.png'],
        'restore_matches_fixed':captures['legacy.png']==captures['restored.png'],
        'saved_overrides_visible':captures['hidden.png']==captures['reloaded.png'],
        'reload_restore_matches_fixed':captures['legacy.png']==captures['reload-restored.png'],
    }
    (out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(report['visual_checks']),flush=True)
    if not all(report['visual_checks'].values()):raise SystemExit(1)

if __name__=='__main__':main()

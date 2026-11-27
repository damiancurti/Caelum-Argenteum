"""Check standalone title, resource coverage and native player events."""
from pathlib import Path
import argparse,hashlib,json,re,shutil,subprocess,time,zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--package',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--map',choices=['MAP01','MAP02'],default='MAP01')
    parser.add_argument('--load-save',type=Path)
    parser.add_argument('--registration-overlay',action='store_true',help='Diagnostic only: register the own TEXTURES include at archive root')
    args=parser.parse_args();package=args.package.resolve(strict=True)
    with zipfile.ZipFile(package) as z:assert z.testzip() is None
    package_hash=hashlib.sha256(package.read_bytes()).hexdigest()
    out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    inventory=json.loads((ROOT/'assets/distribution/INVENTORY.json').read_text(encoding='utf8'))
    textures=sorted(set(inventory['map_texture_references'])|{'PUFFA0','PUFFB0','PUFFC0','PUFFD0','BLUDA0','BLUDB0','BLUDC0','M_EPISOD','M_NEWG','M_SKILL','SW2EXIT','ARM1A0','ARM1B0','ARM2A0','ARM2B0'}|{'FAXE'+c+'0' for c in 'FGHIJK'})
    baseline=json.loads((ROOT/'assets/source/art/standalone_467/BASELINE_DIMENSIONS.json').read_text())
    dimensions=''
    for name,row in (baseline['sprites']|baseline['textures']).items():
        dimensions+=f'{{ let size=TexMan.GetScaledSize(TexMan.CheckForTexture("{name}")); CA467Probe.Check(abs(size.X-{row["width"]})<0.01 && abs(size.Y-{row["height"]})<0.01,"native dimensions {name}"); }}\n'
    texture_probe='class CA467Textures : Object { static ui void Run() {\n'+''.join(f'CA467Probe.Check(TexMan.CheckForTexture("{name}",TexMan.Type_Any).isValid(),"texture {name}");\n' for name in textures)+dimensions+'}}\n'
    with zipfile.ZipFile(out/'checks.pk3','x') as z:
        for name,blob in {'ZSCRIPT':b'version "4.14.2"\n#include "probe.zs"\n#include "texture_probe.zs"\n',
            'probe.zs':(HERE/'standalone_probe.zs').read_bytes(),'texture_probe.zs':texture_probe.encode(),
            'MAPINFO':b'gameinfo { AddEventHandlers="CA467Probe" }\n'}.items():z.writestr(zipfile.ZipInfo(name,(2026,11,26,0,0,0)),blob)
        if args.registration_overlay:z.writestr('TEXTURES.caelum467',b'#include "caelum/data/standalone.textures"\n')
    (out/'session.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nwin_w=1296\nwin_h=759\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=es\n',encoding='utf8')
    if args.load_save:shutil.copyfile(args.load_save,out/'input.zds')
    enter='load input.zds' if args.load_save else 'map '+args.map
    (out/'commands.cfg').write_text(f'wait 105; event ca467_title; playersounds; wait 5; screenshot title.png; wait 3; event ca467_close; {enter}; wait 210; netevent ca467_world {int(args.map[-1])}; wait 5; screenshot world.png; wait 3; event ca467_close; event ca467_gallery 1; wait 5; screenshot resources.png; wait 3; event ca467_gallery 0; save standalone; wait 10; event ca467_done; wait 3; quit\n')
    command=[str(ENGINE),'-noautoload','-iwad',str(package),'-file',str(out/'checks.pk3'),'-config',str(out/'session.ini'),'-savedir',str(out),'-window','+logfile',str(out/'native.log'),'+exec',str(out/'commands.cfg')]
    (out/'command.json').write_text(json.dumps(command,indent=2)+'\n')
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=4
    with (out/'stdout.txt').open('wb') as stream:
        process=subprocess.Popen(command,cwd=out,startupinfo=startup,stdout=stream,stderr=stream);deadline=time.monotonic()+180
        while process.poll() is None:
            log=(out/'stdout.txt').read_text(errors='replace')
            if any(s in log for s in ['Script error,','errors while parsing scripts','Execution could not continue','VM execution aborted']) or time.monotonic()>deadline:
                process.terminate();process.wait(timeout=10);break
            time.sleep(1)
    log=(out/'native.log').read_text(errors='replace') if (out/'native.log').exists() else (out/'stdout.txt').read_text(errors='replace')
    failures=re.findall(r'CA467 FAIL (.*)',log)
    voice_targets=[]
    for voice in ['male','female']:
        for gender in ['male','female','other']:
            match=re.search(r'caelum_'+voice+', '+gender+r':\s*\n((?: [^\n]*\n)+)',log)
            mapping=dict(re.findall(r' (\*\S+)\s+(\S+)',match[1])) if match else {}
            expected='caelum/player/pain_'+voice
            for event in ['death','xdeath','gibbed','pain100','pain75','pain50','pain25','grunt','land','usefail']:
                if mapping.get('*'+event)!=expected:failures.append(f'Native player alias {voice}/{gender}/{event} does not resolve to {expected}')
                else:voice_targets.append(f'{voice}/{gender}/{event}')
    report={'issue':467,'registration_overlay':args.registration_overlay,'map':args.map,'loaded_save':str(args.load_save) if args.load_save else None,'package_sha256':package_hash,'unchanged':hashlib.sha256(package.read_bytes()).hexdigest()==package_hash,
        'exit':process.returncode,'passed_checks':len(re.findall(r'CA467 PASS ',log)),'failures':failures,
        'completed':'CA467 COMPLETE' in log and 'CA467 WORLD COMPLETE' in log,
        'commercial_iwad_loaded':bool(re.search(r'adding .*[/\\](?:DOOM2?\.WAD|id24res\.wad)',log,re.I)),
        'native_voice_targets_verified':len(voice_targets),'saved':(out/'standalone.zds').exists()}
    (out/'SUMMARY.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({key:value for key,value in report.items() if key!='failures'}|{'failure_count':len(failures)}),flush=True)
    if process.returncode or failures or not report['completed'] or not report['saved'] or report['commercial_iwad_loaded']:raise SystemExit(1)


if __name__=='__main__':main()

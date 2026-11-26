"""Inspect regional materials with preserved folklore pilots in an isolated native map."""
from pathlib import Path
import argparse
import json
import shutil
import subprocess
import time
from build_gallery import ROOT, SOURCE, build, digest

ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['runtime','output']:parser.add_argument('--'+name,type=Path,required=True)
    parser.add_argument('--materials',type=Path,help='Optional regional material preview overlay before full-package installation.')
    parser.add_argument('--interactive',action='store_true',help='Open the art gallery for author inspection without automatic acceptance.')
    parser.add_argument('--visual-only',action='store_true',help='Inspect one fresh scene without claiming save continuity.')
    parser.add_argument('--reload-from',type=Path,help='Diagnose a preserved isolated gallery checkpoint without repeating the fresh scene.')
    args=parser.parse_args();runtime=args.runtime.resolve(strict=True)
    materials=args.materials.resolve(strict=True) if args.materials else None
    if b'"gzdoom.exe"' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).lower():
        parser.error('Another native engine is running.')
    out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    fixture,manifest=build(out)
    config=json.loads((SOURCE/'GALLERY.json').read_text())
    ini=out/'session.ini'
    ini.write_text('[LastRun]\nVersion=225\n[GlobalSettings]\nvid_preferbackend=1\nvid_fullscreen=false\nvid_defwidth=1280\nvid_defheight=720\nwin_w=1296\nwin_h=759\nvid_maxfps=60\nvid_vsync=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nlanguage=enu\n')
    common='screenblocks 12; crosshair 0; con_notifytime 0; '
    fresh=common+'wait 140; netevent ca463_prepare; wait 35; netevent ca463_verify; '
    motion='netevent ca463_motion_start; wait 7; netevent ca463_motion_verify; wait 5; '
    views=''.join(f'netevent ca463_view {index}; wait 20; screenshot {item["id"]}.png; wait 5; '
                  for index,item in enumerate(config['views']) if not item.get('control'))
    runs=[('fresh',['+map',config['map']],fresh+views+motion+'save gallery-new; wait 20; quit\n'),
          ('reload',['-loadgame','gallery-new.zds'],common+'wait 35; netevent ca463_verify; '+motion+
           'netevent ca463_walk_start; +forward; wait 70; -forward; wait 5; netevent ca463_walk_verify; wait 5; '
           f'netevent ca463_cross_start; wait 5; +moveright; wait {config["crossing_test"]["input_tics"]}; -moveright; wait 5; netevent ca463_cross_verify; wait 5; '
           'netevent ca463_view 0; wait 20; screenshot reload.png; wait 5; quit\n')]
    if args.visual_only:runs=[('visual',['+map',config['map']],fresh+views+motion+'quit\n')]
    if args.reload_from:
        checkpoint=args.reload_from.resolve(strict=True);checkpoint.relative_to(ROOT/'build')
        if args.visual_only or args.interactive:parser.error('--reload-from cannot be combined with other run modes.')
        shutil.copyfile(checkpoint,out/'gallery-new.zds')
        runs=[('reload',['-loadgame','gallery-new.zds'],runs[1][2])]
    if args.interactive:
        binds=''.join(f'bind F{index+1} "netevent ca463_view {index}"; ' for index in range(len(config['views'])))
        runs=[('interactive',['+map',config['map']],fresh+binds+'\n')]
        print('F1 overview; F2 Litoral; F3 Selva; F4 Patagonia; F5 walk; F6 Cuero; F7 Nahuelito; F8-F10 repeated ground materials. These are visual pilots, not campaign encounters. Close the game after review.',flush=True)
    report=dict(issue=463,scope='Isolated visual gallery, native movement/animation and saved references; no combat or campaign acceptance.',runtime_sha256=digest(runtime.read_bytes()),
                materials_sha256=digest(materials.read_bytes()) if materials else None,fixture_sha256=manifest['fixture_sha256'],engine_sha256=digest(ENGINE.read_bytes()),runs=[])
    for label,entry,commands in runs:
        cfg=out/(label+'.cfg');cfg.write_text(commands)
        command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(runtime)]
        if materials:command.append(str(materials))
        command += [str(fixture),'-config',str(ini),'-savedir',str(out),'-window','+logfile',str(out/(label+'.log')),*entry,'+exec',str(cfg)]
        if args.interactive:
            subprocess.run(command,cwd=out,check=True)
            return
        command.insert(2,'-nomouse')
        startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
        with (out/(label+'-process.log')).open('wb') as stream:
            process=subprocess.Popen(command,cwd=out,startupinfo=startup,stdout=stream,stderr=stream)
            deadline=time.monotonic()+120
            while process.poll() is None and time.monotonic()<deadline:
                logpath=out/(label+'.log');log=logpath.read_text(errors='replace') if logpath.exists() else ''
                if any(token in log for token in ['Script error','Execution could not continue','VM execution aborted','FATAL ERROR','Cannot find savegame']):break
                time.sleep(.2)
            if process.poll() is None:process.terminate()
            code=process.wait(timeout=10)
        logpath=out/(label+'.log');log=logpath.read_text(errors='replace') if logpath.exists() else ''
        errors=[line for line in log.splitlines() if any(token in line for token in ['Script error','Execution could not continue','VM execution aborted','Unknown command','Unknown texture','Unable to load model','FATAL ERROR','Cannot find savegame','CA463 FAIL'])]
        assertions=sum(line.startswith('CA463 PASS') for line in log.splitlines())
        expected=20 if label=='reload' else 16
        result=dict(phase=label,exit_code=code,passed=code==0 and not errors and 'CA463 COMPLETE failures=0' in log and assertions==expected,errors=errors,
                    assertions=assertions,expected_assertions=expected)
        report['runs'].append(result);report['captures']={path.name:digest(path.read_bytes()) for path in sorted(out.glob('*.png'))}
        (out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
        print(json.dumps(result),flush=True)
        if not result['passed']:raise SystemExit(1)


if __name__=='__main__':main()

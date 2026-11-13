"""Narrow the verified #455 native action/loot probe to Cuero and Mandinga."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import shutil
import subprocess
import time
import zipfile
from run_cuero import ROOT, ENGINE, IWAD, digest


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['runtime','output']:parser.add_argument('--'+name,type=Path,required=True)
    args=parser.parse_args();runtime=args.runtime.resolve(strict=True)
    if b'"gzdoom.exe"' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).lower():parser.error('Another native engine is running.')
    out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    original=ROOT/'assets/validation_v5_16_3/bestiary_combat_probe.zs';source=original.read_text(encoding='utf-8')
    replacements=[('for(int i=0;i<CaelumBestiaryData.COUNT;i++)\n        {','for(int i=0;i<CaelumBestiaryData.COUNT;i++)\n        {\n            if(i!=52)continue;'),
        ('Bodies.Size()==56','Bodies.Size()==1'),('Drops.Size()==56','Drops.Size()==1'),('ActionCount==18','ActionCount==6'),
        ('"56 new classes"','"one Cuero class"'),
        ('        Check(Bodies[4].BestiaryReference()=="CA-FOLK-005" && !(Bodies[4] is "CaelumRulo"),"repeatable Ucumar is not Rulo");\n',''),
        ('if(!okay){Failures++;','Console.Printf("CA660 ACTIONCHECK %s %s",okay?"PASS":"FAIL",label);\n        if(!okay){Failures++;')]
    for before,after in replacements:
        if before not in source:raise ValueError('Original probe changed: '+before)
        source=source.replace(before,after)
    (out/'fixture.zs').write_bytes(source.encode())
    spec=importlib.util.spec_from_file_location('old_room',ROOT/'assets/validation_v5_16_3/run_nahuelito_preview.py')
    room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
    package=out/'fixture.pk3'
    with zipfile.ZipFile(package,'w') as archive:
        for name,blob in {'ZSCRIPT':('version "4.14.2"\n'+source).encode(),'maps/CA455V.wad':room.wad(),
            'MAPINFO':b'gameinfo { AddEventHandlers="CA455CombatProbe" }\nmap CA455V "Cuero action and loot diagnostic" { sky1="CABASKY",0 nointermission }\n'}.items():
            archive.writestr(zipfile.ZipInfo(name,(2026,11,13,0,0,0)),blob)
    report=dict(issue=660,runtime_sha256=digest(runtime),source_probe_sha256=digest(original),fixture_sha256=digest(package),runs=[])
    for phase in ['actions','loot','loot-reload']:
        folder=out/phase;folder.mkdir();entry=['+map','CA455V']
        commands='wait 70; netevent ca455_prepare; wait 70; netevent ca455_audit; '
        if phase=='actions':
            commands+=''.join(f'netevent ca455_action {index} {mode}; wait 147; ' for index in [-1,52] for mode in range(3))
            commands+='netevent ca455_action_result; wait 10; quit\n'
        elif phase=='loot':
            commands+='netevent ca455_loot; wait 35; netevent ca455_audit_loot; wait 5; netevent ca455_audit_loot; wait 5; save checkpoint; wait 15; quit\n'
        else:
            shutil.copyfile(out/'loot/checkpoint.zds',folder/'input.zds');entry=['-loadgame','input.zds']
            commands='wait 35; netevent ca455_audit_loot; wait 5; netevent ca455_audit_loot; wait 5; quit\n'
        ini=folder/'session.ini';ini.write_text('[GlobalSettings]\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\nsnd_mastervolume=0.05\ni_soundinbackground=true\nvid_fullscreen=false\nvid_maxfps=60\n')
        cfg=folder/'commands.cfg';cfg.write_text(commands)
        command=[str(ENGINE),'-noautoload','-nomouse','-iwad',str(IWAD),'-file',str(runtime),str(package),'-config',str(ini),'-savedir',str(folder),'-window','+logfile',str(folder/'engine.log'),*entry,'+exec',str(cfg)]
        startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
        fatal=['Script error','Execution could not continue','VM execution aborted','FATAL ERROR','Cannot find savegame']
        with (folder/'process.log').open('wb') as stream:
            process=subprocess.Popen(command,cwd=folder,startupinfo=startup,stdout=stream,stderr=stream);deadline=time.monotonic()+180
            while process.poll() is None and time.monotonic()<deadline:
                logpath=folder/'engine.log';log=logpath.read_text(errors='replace') if logpath.exists() else ''
                if any(token in log for token in fatal):break
                time.sleep(.2)
            if process.poll() is None:process.terminate()
            code=process.wait(timeout=10)
        log=(folder/'engine.log').read_text(errors='replace') if (folder/'engine.log').exists() else ''
        errors=[line for line in log.splitlines() if any(token in line for token in fatal+['CA660 ACTIONCHECK FAIL','CA455 ACTION FAIL','CA455 ACTIONS FAIL','CA455 LOOT FAIL','Unknown command','Unable to load model'])]
        actions=[line for line in log.splitlines() if line.startswith('CA455 ACTION PASS')]
        loot=sum(line.startswith('CA455 LOOT PASS') for line in log.splitlines())
        passed=code==0 and not errors and (len(actions)==6 and 'CA455 ACTIONS PASS completed=6' in log if phase=='actions' else loot==2)
        if phase=='loot':passed &= (folder/'checkpoint.zds').exists()
        result=dict(phase=phase,exit_code=code,passed=passed,errors=errors,assertions=sum(line.startswith('CA660 ACTIONCHECK PASS') for line in log.splitlines()),actions=actions,loot_audits=loot)
        report['runs'].append(result);(out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
        print(json.dumps(result),flush=True)
        if not passed:raise SystemExit(1)


if __name__=='__main__':main()

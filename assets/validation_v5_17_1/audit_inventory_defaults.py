"""Read native inventory defaults without spawning items or executing their actions.

The bounded once-only catalogue observation separates internal/nonphysical types
from possible world drops. Catalogue variants and custom drop policy still need
explicit coverage; this is discovery, not final model acceptance.
"""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import sys
import time
import zipfile

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/validation_v5_16_3'))
from run_nahuelito_preview import wad
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['runtime','candidates','output']:parser.add_argument('--'+name,type=Path,required=True)
    args=parser.parse_args();runtime=args.runtime.resolve(strict=True);candidates=args.candidates.resolve(strict=True)
    inventory=json.loads(candidates.read_text(encoding='utf-8'))['candidates']
    active=subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).decode(errors='replace')
    if '"gzdoom.exe"' in active.lower():parser.error('Another native engine is running.')
    out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    source='''class CA647InventoryDefaults : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca647_audit")return;
        static const class<Inventory> kinds[]={KINDS};
        for(int index=0;index<kinds.Size();index++)
        {
            let item=GetDefaultByType(kinds[index]);let state=item.SpawnState;
            bool hasSpawn=state!=null && state!=GetDefaultByType('Actor').SpawnState;
            bool visible=hasSpawn && state.sprite!=Actor.GetSpriteIndex('TNT1');
            Console.Printf("CA647 DEFAULT|%s|%d|%d|%d|%d|%s|%d|%d|%d|%d|%.5f|%.5f|%.5f|%.5f",
                item.GetClassName(),item.bUndroppable,item.bUntossable,hasSpawn,visible,TexMan.GetName(item.Icon),
                item.Amount,item.MaxAmount,state!=null?state.sprite:-1,state!=null?state.Frame:-1,
                item.Radius,item.Height,item.Scale.X,item.Scale.Y);
        }
        Console.Printf("CA647 COMPLETE count=%d",kinds.Size());
    }
}'''.replace('KINDS',','.join("'%s'"%entry['class'] for entry in inventory))
    (out/'audit.zs').write_text(source,encoding='utf-8')
    fixture=out/'fixture.pk3'
    with zipfile.ZipFile(fixture,'w') as package:
        for name,blob in {'ZSCRIPT':('version "4.14.2"\n'+source).encode(),'maps/CA455V.wad':wad(),
            'MAPINFO':b'gameinfo { AddEventHandlers="CA647InventoryDefaults" }\nmap CA455V "Inventory default audit" { sky1="CABASKY",0 nointermission }\n'}.items():
            package.writestr(zipfile.ZipInfo(name,(2026,11,13,0,0,0)),blob)
    (out/'session.ini').write_text('[LastRun]\nVersion=225\n[GlobalSettings]\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nvid_fullscreen=false\nvid_defwidth=1280\nvid_defheight=720\nwin_w=1296\nwin_h=759\n')
    (out/'commands.cfg').write_text('wait 140; netevent ca647_audit; wait 35; quit\n')
    command=[str(ENGINE),'-noautoload','-nomouse','-iwad',str(IWAD),'-file',str(runtime),str(fixture),'-config',str(out/'session.ini'),'-savedir',str(out),'-window','+logfile',str(out/'engine.log'),'+map','CA455V','+exec',str(out/'commands.cfg')]
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    with (out/'process.log').open('wb') as stream:
        process=subprocess.Popen(command,cwd=out,stdout=stream,stderr=stream,startupinfo=startup);deadline=time.monotonic()+90
        while process.poll() is None and time.monotonic()<deadline:
            text=(out/'engine.log').read_text(errors='replace') if (out/'engine.log').exists() else ''
            if any(key in text for key in ['Script error','Execution could not continue','VM execution aborted']):break
            time.sleep(.2)
        if process.poll() is None:process.terminate()
        code=process.wait(timeout=10)
    log=(out/'engine.log').read_text(errors='replace') if (out/'engine.log').exists() else ''
    errors=[line for line in log.splitlines() if any(key in line for key in ['Script error','Execution could not continue','VM execution aborted','Unknown command'])]
    entries=[]
    for line in log.splitlines():
        if not line.startswith('CA647 DEFAULT|'):continue
        values=line.split('|')
        entries.append(dict(zip(['class','undroppable','untossable','has_spawn','visible_spawn','icon','amount','max_amount','sprite','frame','radius','height','scale_x','scale_y'],values[1:])))
    passed=code==0 and not errors and len(entries)==len(inventory) and f'CA647 COMPLETE count={len(inventory)}' in log
    report={'issue':647,'scope':__doc__.strip(),'runtime_sha256':digest(runtime),'candidates_sha256':digest(candidates),'fixture_sha256':digest(fixture),
            'engine_sha256':digest(ENGINE),'exit_code':code,'errors':errors,'passed':passed,'defaults':entries}
    (out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n')
    possible=[entry for entry in entries if entry['undroppable']=='0' and entry['untossable']=='0' and entry['visible_spawn']=='1']
    print(json.dumps({'passed':passed,'observed_defaults':len(entries),'possible_visible_drop_types':len(possible),'errors':errors}),flush=True)
    if not passed:raise SystemExit(1)

if __name__=='__main__':main()

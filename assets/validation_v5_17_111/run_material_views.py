"""Capture #866 material pairs, native texture sizes and bounded movement.

Diagnostic teleports, menu dismissal, invulnerability and notarget affect only
the disposable inspection pawn. This is not a full campaign/locked-route test.
One hidden, unpaused native engine at 5% audio runs at a time.
GZDoom4.14.2 GetSize returns rounded display dimensions, not PNG texels. The
retained native logs use the historical field label raw for that value; the
portable fixture labels it display_int. PNG dimensions are verified separately.
"""
from pathlib import Path
import argparse
import hashlib
import json
import re
import struct
import subprocess
import sys
import time
import zipfile

ROOT = Path(__file__).resolve().parents[2]
ENGINE = Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD = Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
SOURCE = ROOT / 'assets/source/art/environment_remasters_866'
SHA = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
FATAL = ('Script error', 'Execution could not continue', 'VM execution aborted', 'compile errors', 'DIED WITH FATAL ERROR', 'CA866 FAIL')


def laboratory(names):
    blocks = ['namespace="zdoom";']
    for i, name in enumerate(names):
        x = i * 512
        for px, py in [(x, 0), (x, 384), (x + 384, 384), (x + 384, 0)]:
            blocks.append(f'vertex {{ x={px};y={py}; }}')
        blocks.append(f'sector {{ heightfloor=0;heightceiling=256;texturefloor="{name}";textureceiling="{name}";lightlevel=208; }}')
        for j in range(4):
            blocks.append(f'sidedef {{ sector={i};texturemiddle="{name}"; }}')
            blocks.append(f'linedef {{ v1={i*4+j};v2={i*4+(j+1)%4};sidefront={i*4+j};blocking=true; }}')
    blocks.append('thing { x=128;y=128;type=1;angle=45;skill1=true;skill2=true;skill3=true;skill4=true;skill5=true;single=true;coop=true; }')
    lumps = [('C866LAB', b''), ('TEXTMAP', '\n'.join(blocks).encode()), ('ENDMAP', b'')]
    data = bytearray(b'\0' * 12)
    entries = []
    for name, content in lumps:
        entries.append((len(data), len(content), name.encode().ljust(8, b'\0')))
        data.extend(content)
    directory = len(data)
    for row in entries:
        data.extend(struct.pack('<ii8s', *row))
    struct.pack_into('<4sii', data, 0, b'PWAD', len(entries), directory)
    return bytes(data)


def fixture(out, points, names, aliases):
    cases = '\n'.join(f'case {i}: point=({r["point"][0]},{r["point"][1]},0); angle={r["angle"]}; pitch={r.get("pitch",0)}; break;' for i, r in enumerate(points))
    source = '''class CA866Views : EventHandler
{
    int View;
    vector3 WalkStart;
    override void UiTick()
    { if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close(); }
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);if(user==null)return;
        let record=user.GetPersistentCharacterState(true);
        CaelumDemoNarrative.EnsureRevision(record);
        record.DemoNarrativeDelivered=2047;record.DemoNarrativePending=0;
        user.bInvulnerable=true;user.bNOTARGET=true;
    }
    void Sizes()
    {
        static const String names[]={NAMES};
        for(int i=0;i<names.Size();i++)for(int kind=TexMan.Type_Wall;kind<=TexMan.Type_Flat;kind++)
        {
            let texture=TexMan.CheckForTexture(names[i],kind);
            let size=TexMan.GetScaledSize(texture);
            int width,height;[width,height]=TexMan.GetSize(texture);
            Console.Printf("CA866 SIZE %s kind=%d display_int=%dx%d scaled=%.3fx%.3f",names[i],kind,width,height,size.X,size.Y);
            if(size.X!=128 || size.Y!=128)Console.Printf("CA866 FAIL texture scale %s",names[i]);
        }
    }
    void Place(int index)
    {
        let user=CaelumPlayer(players[0].mo);
        if(user==null){Console.Printf("CA866 FAIL player");return;}
        vector3 point;double angle,pitch;
        switch(index) { CASES default:Console.Printf("CA866 FAIL index");return; }
        user.SetOrigin(point,false);user.FindFloorCeiling();
        user.SetOrigin((point.X,point.Y,user.FloorZ),false);
        user.Angle=angle;user.Pitch=pitch;user.Vel=(0,0,0);
        Console.Printf("CA866 VIEW %d pos=%.3f,%.3f,%.3f angle=%.3f headroom=%.3f height=%.3f floor=%s ceiling=%s",index,user.Pos.X,user.Pos.Y,user.Pos.Z,user.Angle,user.CeilingZ-user.FloorZ,user.Height,TexMan.GetName(user.CurSector.GetTexture(Sector.floor)),TexMan.GetName(user.CurSector.GetTexture(Sector.ceiling)));
        if(user.CeilingZ-user.FloorZ<user.Height)Console.Printf("CA866 FAIL clearance");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca866_next"){if(View==0)Sizes();Place(View);View++;}
        else if(e.Name=="ca866_walk"){Place(0);WalkStart=players[0].mo.Pos;}
        else if(e.Name=="ca866_done")
        {
            let user=players[0].mo;double distance=(user.Pos-WalkStart).Length();
            Console.Printf("CA866 WALK distance=%.3f pos=%.3f,%.3f,%.3f",distance,user.Pos.X,user.Pos.Y,user.Pos.Z);
            Console.Printf("CA866 %s views=%d",View==COUNT && distance>0?"PASS":"FAIL",View);
        }
    }
}
'''.replace('CASES', cases).replace('COUNT', str(len(points))).replace('NAMES', ','.join(json.dumps(n) for n in aliases))
    (out / 'probe.zs').write_text(source, encoding='utf-8', newline='\n')
    package = out / 'views.pk3'
    members = {'ZSCRIPT': b'version "4.14.2"\n#include "probe.zs"\n',
               'MAPINFO': b'gameinfo { AddEventHandlers="CA866Views" }\nmap C866LAB "Author material repeat review" { levelnum=866 nointermission }\n',
               'probe.zs': source.encode(), 'maps/C866LAB.wad': laboratory(names)}
    with zipfile.ZipFile(package, 'x') as z:
        for name, data in sorted(members.items()):
            z.writestr(zipfile.ZipInfo(name, (2026,11,21,0,0,0)), data)
    return package


def run(runtime, overlay, out, points, probe, label, map_name):
    active = subprocess.check_output(['tasklist', '/FI', 'IMAGENAME eq gzdoom.exe', '/FO', 'CSV', '/NH'], text=True, errors='replace')
    if 'gzdoom.exe' in active.lower():
        raise RuntimeError('Another native engine is running; finish that session first.')
    folder = out / label
    folder.mkdir()
    config = folder / 'session.ini'
    config.write_text('[LastRun]\nVersion=225\n[GlobalSettings]\nvid_preferbackend=1\nvid_vsync=false\nvid_maxfps=0\ncl_capfps=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\nsnd_mastervolume=0.05\ni_soundinbackground=true\nvid_fullscreen=false\nvid_defwidth=1280\nvid_defheight=720\nuse_mouse=false\nlanguage=enu\n', encoding='utf-8')
    commands = ['con_notifytime 0', 'wait 140']
    for row in points:
        commands += ['netevent ca866_next', 'wait 35', 'screenshot '+row['name']+'.png', 'wait 5']
    commands += ['netevent ca866_walk', 'wait 5', '+forward', 'wait 35', '-forward', 'wait 5', 'netevent ca866_done', 'screenshot walk.png', 'wait 5', 'quit']
    cfg = folder / 'start.cfg'
    cfg.write_text('; '.join(commands)+'\n', encoding='utf-8')
    command = [str(ENGINE), '-noautoload', '-nomouse', '-iwad', str(IWAD), '-file', str(runtime), *([str(overlay)] if label=='candidate' else []), str(probe), '-config', str(config), '-savedir', str(folder), '-window', '-width', '1280', '-height', '720', '-rngseed', '428', '+logfile', str(folder/'engine.log'), '+map', map_name, '+exec', str(cfg)]
    startup = subprocess.STARTUPINFO()
    startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    startup.wShowWindow = 0
    timed_out = False
    with (folder/'process.log').open('wb') as stream:
        process = subprocess.Popen(command, cwd=folder, startupinfo=startup, stdout=stream, stderr=stream)
        deadline = time.monotonic()+180
        while process.poll() is None:
            log = folder/'engine.log'
            text = log.read_text(errors='replace') if log.exists() else ''
            if any(t in text for t in FATAL):
                break
            if time.monotonic()>deadline:
                timed_out=True
                break
            time.sleep(.25)
        if process.poll() is None:
            process.terminate()
            process.wait(timeout=10)
    text = (folder/'engine.log').read_text(errors='replace')
    errors = [t for t in FATAL if t in text]
    images = [r['name']+'.png' for r in points]+['walk.png']
    result = dict(label=label, passed=not timed_out and not errors and process.returncode==0 and f'CA866 PASS views={len(points)}' in text and all((folder/n).exists() for n in images), exit_code=process.returncode, timed_out=timed_out, errors=errors, command=command, markers=[s for s in text.splitlines() if 'CA866 ' in s], images={n:SHA(folder/n) for n in images if (folder/n).exists()})
    (folder/'RESULTS.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(dict(label=label,map=map_name,passed=result['passed'],errors=errors,images=len(result['images']))),flush=True)
    return result


def main():
    p=argparse.ArgumentParser(description=__doc__)
    for name in ('runtime','overlay','output'):
        p.add_argument('--'+name,type=Path,required=True)
    p.add_argument('--map',choices=['C866LAB','MAP01','MAP02','MAP03'],required=True)
    p.add_argument('--view',help='Optional named camera from the retained view data')
    a=p.parse_args()
    data=json.loads((SOURCE/'VIEWS.json').read_text(encoding='utf-8'))
    inventory=json.loads((SOURCE/'INVENTORY.json').read_text(encoding='utf-8'))
    out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    points=data[a.map]
    if a.view:
        points=[row for row in points if row['name']==a.view]
        if not points:raise ValueError('Unknown camera: '+a.view)
    names=[Path(r['file']).stem for r in inventory['exports']]
    probe=fixture(out,points,names,inventory['aliases']);results=[]
    for label in ('control','candidate'):
        result=run(a.runtime.resolve(),a.overlay.resolve(),out,points,probe,label,a.map)
        results.append(result)
        if not result['passed']:break
    report=dict(issue=866,map=a.map,runtime_sha256=SHA(a.runtime),overlay_sha256=SHA(a.overlay),engine_sha256=SHA(ENGINE),probe_sha256=SHA(probe),cameras=points,runs=results,passed=len(results)==2 and all(r['passed'] for r in results),qualification=__doc__)
    (out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    raise SystemExit(not report['passed'])


if __name__=='__main__':main()

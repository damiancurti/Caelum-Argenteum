"""Compare original atlas clips and candidate frames in the same native render."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,re,shutil,struct,subprocess,time,zipfile
from PIL import Image,ImageChops
root=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--candidate',type=Path);p.add_argument('--reference-runtime',type=Path,required=True);p.add_argument('--load',type=Path);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
out=a.output.resolve();out.relative_to(root/'build');out.mkdir(exist_ok=False)
inventory=subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).decode(errors='replace')
assert '"gzdoom.exe"' not in inventory.lower(),'Another engine is running.'
with zipfile.ZipFile(a.reference_runtime) as z:bindings=z.read('graphics/caelum/vfx/elemental.textures').decode('utf-8')
lines=[line for line in bindings.splitlines() if 'Patch "graphics/caelum/vfx/projectiles.png"' in line];assert len(lines)==36
names=[re.search(r'Sprite "(\w+)"',line)[1] for line in lines]
aliases=[f'Q8{i//4:02d}{chr(65+i%4)}0' for i in range(36)]
reference='\n'.join(line.replace('"'+name+'"','"'+alias+'"',1) for line,name,alias in zip(lines,names,aliases))+'\n'
strings=lambda v:','.join('"'+s+'"' for s in v)
source='''class CA840PixelView : EventHandler
{
    transient ui bool Checked;
    transient ui int Background;
    transient bool SavedChecked;
    override void OnRegister(){SetOrder(2147483647);}
    override void WorldLoaded(WorldEvent e)
    {
        String current[]={CURRENT};
        if(!e.IsSaveGame)for(int i=0;i<36;i++)
        {
            let holder=CA840SavedFrame(Actor.Spawn("CA840SavedFrame",(0,0,64),NO_REPLACE));
            holder.Index=i;holder.SelectFrame(i);
        }
    }
    override void WorldTick()
    {
        if(SavedChecked)return;SavedChecked=true;
        String current[]={CURRENT};
        int count=0,failures=0;bool seen[36];
        let it=ThinkerIterator.Create("CA840SavedFrame");CA840SavedFrame holder;
        while((holder=CA840SavedFrame(it.Next()))!=null)
        {
            int i=holder.Index;bool valid=i>=0 && i<36;
            if(valid){valid=!seen[i] && holder.sprite==holder.GetSpriteIndex(current[i].Left(4)) && holder.frame==i%4;seen[i]=true;}
            if(!valid)failures++;count++;
            Console.Printf("CA840 SAVED_FRAME %s index=%d",valid?"PASS":"FAIL",i);
        }
        if(count!=36)failures++;
        Console.Printf("CA840 SAVED_FRAME_RESULT count=%d failures=%d",count,failures);
    }
    override void ConsoleProcess(ConsoleEvent e)
    {if(e.Name=="ca840white")Background=2;else if(e.Name=="ca840gray")Background=1;}
    override void RenderOverlay(RenderEvent e)
    {
        String current[]={CURRENT};String reference[]={REFERENCE};
        int color=Background==2?0xFFFFFF:Background==1?0x606060:0;
        Screen.Clear(0,0,Screen.GetWidth(),Screen.GetHeight(),color);
        int failures=0;
        for(int i=0;i<36;i++)
        {
            let c=TexMan.CheckForTexture(current[i],TexMan.Type_Sprite);
            let r=TexMan.CheckForTexture(reference[i],TexMan.Type_Sprite);
            bool valid=c.IsValid() && r.IsValid();
            if(valid)
            {
                int cw,ch,rw,rh;[cw,ch]=TexMan.GetSize(c);[rw,rh]=TexMan.GetSize(r);
                valid=cw==rw && ch==rh && TexMan.GetScaledSize(c)==TexMan.GetScaledSize(r) && TexMan.GetScaledOffset(c)==TexMan.GetScaledOffset(r);
                double x=55+(i%6)*100;double y=65+(i/6)*100;
                Screen.DrawTexture(r,true,x,y);
                Screen.DrawTexture(c,true,x+640,y);
            }
            if(!valid)failures++;
            if(!Checked)Console.Printf("CA840 PIXEL_META %s frame=%s",valid?"PASS":"FAIL",current[i]);
        }
        if(!Checked){Checked=true;Console.Printf("CA840 PIXEL_META_RESULT checks=36 failures=%d",failures);}
    }
}
'''.replace('CURRENT',strings(names)).replace('REFERENCE',strings(aliases))
source+='\nclass CA840SavedFrame : Actor { int Index; void SelectFrame(int index) { switch(index) { '+' '.join(f'case {i}: SetStateLabel("Frame{i}"); return;' for i in range(36))+' } } Default { +NOGRAVITY +NOINTERACTION } States { Spawn: TNT1 A -1; Stop;\n'+'\n'.join(f'Frame{i}: {name[:4]} {name[4]} -1; Stop;' for i,name in enumerate(names))+'\n} }\n'
spec=importlib.util.spec_from_file_location('fixture',root/'assets/validation_5100/prepare.py');fixture=importlib.util.module_from_spec(spec);spec.loader.exec_module(fixture)
wad=fixture.room()
files={'ZSCRIPT':('version "4.14.2"\n'+source).encode(),'TEXTURES':reference.encode(),'MAPINFO':b'gameinfo { AddEventHandlers="CA840PixelView" }\nmap CA840P "Native pixel comparison" {}\n','maps/CA840P.wad':wad}
checks=out/'checks.pk3'
with zipfile.ZipFile(checks,'x') as z:
    for name,data in sorted(files.items()):z.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),data)
(out/'checks.zs').write_text(source,encoding='utf-8');(out/'reference.textures').write_text(reference,encoding='utf-8')
(out/'session.ini').write_text('[GlobalSettings]\nvid_preferbackend=1\nvid_fullscreen=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\nsnd_mastervolume=0.05\ni_soundinbackground=true\nvid_maxfps=60\nvid_vsync=false\nvid_defwidth=1280\nvid_defheight=720\nwin_w=1296\nwin_h=759\ncon_notifytime=0\nuse_mouse=false\nlanguage=enu\n',encoding='utf-8')
(out/'commands.cfg').write_text('wait 100; screenshot black.png; wait 3; event ca840gray; wait 12; screenshot gray.png; wait 3; event ca840white; wait 12; screenshot white.png; wait 10; save pixels.zds; wait 5; quit\n',encoding='utf-8')
engine=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe');iwad=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
packages=[a.runtime.resolve()]+([a.candidate.resolve()] if a.candidate else [])+[checks]
launch=['+map','CA840P']
if a.load:shutil.copyfile(a.load,out/'input.zds');launch=['-loadgame','input.zds']
command=[str(engine),'-noautoload','-nomouse','-iwad',str(iwad),'-file',*map(str,packages),'-config',str(out/'session.ini'),'-savedir',str(out),'-window','-width','1280','-height','720','+logfile',str(out/'engine.log'),*launch,'+exec',str(out/'commands.cfg')]
startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
with (out/'process.log').open('wb') as log:
    proc=subprocess.Popen(command,cwd=out,stdout=log,stderr=log,startupinfo=startup)
    deadline=time.monotonic()+90
    while proc.poll() is None:
        path=out/'engine.log';sample=path.read_text(encoding='utf-8',errors='replace') if path.exists() else ''
        if any(s in sample for s in ('Script error','VM execution aborted','Execution could not continue','DIED WITH FATAL ERROR')) or time.monotonic()>deadline:
            proc.terminate();break
        time.sleep(.25)
    code=proc.wait(timeout=15)
log=(out/'engine.log').read_text(encoding='utf-8',errors='replace')
errors=[s for s in ('Script error','VM execution aborted','Execution could not continue','DIED WITH FATAL ERROR','CA840 PIXEL_META FAIL','CA840 SAVED_FRAME FAIL') if s in log]
captures=[]
for name in ('black','gray','white'):
    path=out/(name+'.png')
    if not path.exists():errors.append('Missing '+name);continue
    im=Image.open(path).convert('RGB');assert im.size==(1280,720)
    left=im.crop((0,0,640,720));right=im.crop((640,0,1280,720));diff=ImageChops.difference(left,right)
    boxes=[(20+(i%6)*100,30+(i//6)*100,90+(i%6)*100,100+(i//6)*100) for i in range(36)]
    failed=[names[i] for i,b in enumerate(boxes) if diff.crop(b).getbbox() is not None]
    expected={'black':(0,0,0),'gray':(96,96,96),'white':(255,255,255)}[name]
    actual=im.getpixel((0,0))
    if actual!=expected:errors.append(f'Unexpected {name} background: {actual}')
    captures.append(dict(background=name,background_rgb=actual,sha256=hashlib.sha256(path.read_bytes()).hexdigest(),whole_half_equal=diff.getbbox() is None,failed_cells=failed))
    if failed:errors.append('Native pixel differences '+name+': '+','.join(failed))
passed=code==0 and not errors and 'CA840 PIXEL_META_RESULT checks=36 failures=0' in log and 'CA840 SAVED_FRAME_RESULT count=36 failures=0' in log and len(captures)==3 and (out/'pixels.zds').is_file()
report=dict(issue=840,passed=passed,command=command,exit_code=code,errors=errors,captures=captures,checks=[s for s in log.splitlines() if s.startswith('CA840 PIXEL_')],sha256={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in packages},qualification='Same native frame renders original atlas aliases and candidates in paired positions on three opaque backgrounds. Actual unchanged-scale/offset metadata and rendered RGB cells are compared. Isolated compositing evidence, not author acceptance or combat/performance evidence.')
report.update(reference_runtime_sha256=hashlib.sha256(a.reference_runtime.read_bytes()).hexdigest(),loaded_save_sha256=hashlib.sha256(a.load.read_bytes()).hexdigest() if a.load else None,saved_sha256=hashlib.sha256((out/'pixels.zds').read_bytes()).hexdigest() if (out/'pixels.zds').is_file() else None)
report['saved_frame_checks']=[s for s in log.splitlines() if s.startswith('CA840 SAVED_FRAME')]
(out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps(dict(passed=passed,errors=errors,captures=captures),indent=2));raise SystemExit(not passed)

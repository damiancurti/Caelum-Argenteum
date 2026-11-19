"""Exercise the actual shared Candidate query, portal fallback and saved probes."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,shutil,struct,subprocess,time,zipfile
ROOT=Path(__file__).resolve().parents[2]

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime',type=Path,required=True)
    parser.add_argument('--candidate',type=Path)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--load',type=Path)
    parser.add_argument('--portal',action='store_true')
    args=parser.parse_args();out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
    spec=importlib.util.spec_from_file_location('vision_fixture',ROOT/'assets/validation_5100/prepare.py');fixture=importlib.util.module_from_spec(spec);spec.loader.exec_module(fixture)
    wad=fixture.room();count,offset=struct.unpack_from('<ii',wad,4);entry=struct.unpack_from('<ii8s',wad,offset+16);maptext=wad[entry[0]:entry[0]+entry[1]].decode()
    if args.portal:
        maptext=maptext.replace('linedef{v1=2;v2=1;sidefront=0;blocking=true;}','linedef{v1=2;v2=1;sidefront=4;sideback=2;twosided=true;id=8361;special=156;arg0=8362;arg2=3;}')
        maptext+='''
vertex{x=8192;y=-2048;} vertex{x=12288;y=-2048;}
vertex{x=12288;y=2048;} vertex{x=8192;y=2048;}
sector{heightfloor=0;heightceiling=256;texturefloor="FLOOR4_8";textureceiling="CEIL3_5";lightlevel=255;}
sidedef{sector=1;texturemiddle="STARTAN3";}
linedef{v1=9;v2=8;sidefront=1;blocking=true;}
linedef{v1=10;v2=9;sidefront=1;blocking=true;}
linedef{v1=11;v2=10;sidefront=1;blocking=true;}
linedef{v1=8;v2=11;sidefront=5;sideback=3;twosided=true;id=8362;special=156;arg0=8361;arg2=3;}
vertex{x=2304;y=-2048;} vertex{x=2304;y=2048;}
vertex{x=7936;y=-2048;} vertex{x=7936;y=2048;}
sector{heightfloor=0;heightceiling=256;texturefloor="FLOOR4_8";textureceiling="CEIL3_5";lightlevel=255;}
sector{heightfloor=0;heightceiling=256;texturefloor="FLOOR4_8";textureceiling="CEIL3_5";lightlevel=255;}
sidedef{sector=2;texturemiddle="STARTAN3";}
sidedef{sector=3;texturemiddle="STARTAN3";}
sidedef{sector=0;texturemiddle="-";}
sidedef{sector=1;texturemiddle="-";}
linedef{v1=12;v2=1;sidefront=2;blocking=true;}
linedef{v1=13;v2=12;sidefront=2;blocking=true;}
linedef{v1=2;v2=13;sidefront=2;blocking=true;}
linedef{v1=8;v2=14;sidefront=3;blocking=true;}
linedef{v1=14;v2=15;sidefront=3;blocking=true;}
linedef{v1=15;v2=11;sidefront=3;blocking=true;}
'''
    lumps=[('MAP01',b''),('TEXTMAP',maptext.encode()),('ENDMAP',b'')];body=bytearray();directory=bytearray()
    for name,data in lumps:directory+=struct.pack('<ii8s',12+len(body),len(data),name.encode());body+=data
    wad=struct.pack('<4sii',b'PWAD',len(lumps),12+len(body))+body+directory
    source=(ROOT/'assets/validation_v5_16_2/vision_edge_checks.zs').read_text(encoding='utf-8').replace('CA454','CA836').replace('ca454','ca836')
    source='class CA836FrozenPort : CaelumPortSiege { override void PostBeginPlay() {} override void Tick() {} }\n'+source
    old='''        return CaelumVisualPerception.CanSee(Observer,subject);'''
    new='''        let population=CaelumPopulationState.Get();if(population==null)return false;
        bool originalDense=population.HighDensity;population.HighDensity=true;
        if(Observer.SiegeCombatant==null)
        {
            Observer.SiegeCombatant=new("CaelumSiegeCombatant");
            let entry=Observer.SiegeCombatant;entry.Body=Observer;entry.CommandLeader=entry;
            entry.Encounter=CaelumSiegeEncounter(Actor.Spawn('CA836FrozenPort',(-1800,-1800,0),NO_REPLACE));
            entry.GroupCandidates=new("CaelumCommandCandidates");
        }
        let group=Observer.SiegeCombatant.GroupCandidates;
        group.Candidates.Clear();group.Candidates.Push(subject);group.Ready=true;group.SampleTic=level.time;
        let evidence=CaelumVisualPerception.Evidence(Observer);evidence.CandidateCacheReady=false;evidence.PreviousSampleVisible=false;
        Observer.bFriendly=true;
        Actor found=CaelumVisualPerception.Candidate(Observer);
        population.HighDensity=originalDense;
        return found==subject;'''
    assert source.count(old)==1;source=source.replace(old,new)
    old='''        Check(true,"conditions restored");'''
    new=old+'''
        Subject.SetOrigin((1800,0,0),false);Check(false,"far X beyond broadphase");
        Subject.SetOrigin((0,1800,0),false);Observer.Angle=90;Check(false,"far Y beyond broadphase");
        Subject.SetOrigin((900,900,0),false);Observer.Angle=45;Check(false,"diagonal retained for exact distance");
        Subject.SetOrigin((1500,0,0),false);Subject.Height=112;Observer.Angle=0;Check(true,"tall target retained immediately");
        Subject.Height=56;Check(false,"target shrinks immediately");
        Observer.CombatEffectiveInsight=100;Check(true,"far target becomes visible after insight change");
        Observer.CombatEffectiveInsight=0;Subject.CombatAgility=100;Subject.Height=1;Subject.SetOrigin((32.005,0,0),false);Observer.Angle=180;
        Check(true,"contact margin behind with minimal height");
        Subject.SetOrigin((32.02,0,0),false);Check(false,"outside contact margin in full stealth");
        Subject.CombatAgility=0;Subject.Height=56;Subject.SetOrigin((256,0,0),false);Observer.Angle=0;
'''
    if args.portal:
        new+='''
        Checks++;bool portals=level.GetPortalGroupCount()>1;if(!portals)Failures++;
        Console.Printf("CA836 EDGE %s linked portal groups=%d",portals?"PASS":"FAIL",level.GetPortalGroupCount());
        Observer.SetOrigin((1800,0,0),false);Subject.SetOrigin((8440,0,0),false);
        Checks++;bool distance=Abs(Observer.Distance3D(Subject)-496)<0.00001 && Abs(Observer.Pos.X-Subject.Pos.X)>6000;
        if(!distance)Failures++;Console.Printf("CA836 EDGE %s native linked distance=%.6f raw=%.6f",distance?"PASS":"FAIL",Observer.Distance3D(Subject),Abs(Observer.Pos.X-Subject.Pos.X));
        Check(true,"visible through linked portal despite distant coordinates");
        Observer.Angle=180;Check(false,"linked portal behind");Observer.Angle=0;
        Subject.CombatAgility=100;Check(false,"linked portal respects stealth");Subject.CombatAgility=0;
        Observer.SetOrigin((0,0,0),false);Subject.SetOrigin((256,0,0),false);
'''
    assert source.count(old)==1;source=source.replace(old,new)
    files={'ZSCRIPT':('version "4.14.2"\n'+source).encode(),'maps/CA836A.wad':wad,'MAPINFO':b'gameinfo { AddEventHandlers="CA836VisionEdges" }\nmap CA836A "Candidate reach checks" {}\n'}
    checks=out/'checks.pk3'
    with zipfile.ZipFile(checks,'w') as z:
        for name,data in sorted(files.items()):z.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),data)
    (out/'checks.zs').write_text(source,encoding='utf-8');(out/'fixture.txt').write_text(maptext,encoding='utf-8')
    engine=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe');iwad=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
    config=out/'session.ini';config.write_bytes(b'[GlobalSettings]\nvid_preferbackend=1\nvid_fullscreen=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\nsnd_mastervolume=0.05\ni_soundinbackground=true\nvid_maxfps=60\nlanguage=en\n')
    commands=out/'commands.cfg';commands.write_text('wait 100; netevent '+('ca836reload' if args.load else 'ca836seed')+'; wait 10; save reach.zds; wait 10; quit\n',encoding='utf-8')
    packages=[args.runtime.resolve()]+([args.candidate.resolve()] if args.candidate else [])+[checks]
    command=[str(engine),'-noautoload','-nomouse','-iwad',str(iwad),'-file',*map(str,packages),'-config',str(config),'-savedir',str(out),'-window','-width','1280','-height','720','+logfile',str(out/'engine.log')]
    if args.load:shutil.copyfile(args.load,out/'input.zds');command+=['-loadgame','input.zds']
    else:command+=['+map','CA836A']
    command+=['+exec',str(commands)]
    inventory=subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).decode(errors='replace')
    if '"gzdoom.exe"' in inventory.lower():raise SystemExit('Another engine is running; preserve it.')
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    stopped=None
    with (out/'process.log').open('wb') as log:
        proc=subprocess.Popen(command,cwd=out,stdout=log,stderr=log,startupinfo=startup);deadline=time.monotonic()+90
        while proc.poll() is None:
            path=out/'engine.log';sample=path.read_text(encoding='utf-8',errors='replace') if path.exists() else ''
            if any(s in sample for s in ('Script error','VM execution aborted','Execution could not continue','DIED WITH FATAL ERROR')):stopped='Native error'
            if time.monotonic()>deadline:stopped='Timeout'
            if stopped:proc.terminate();break
            time.sleep(.25)
        code=proc.wait(timeout=10)
    text=(out/'engine.log').read_text(encoding='utf-8',errors='replace')
    errors=[s for s in ('Script error','VM execution aborted','Execution could not continue','DIED WITH FATAL ERROR','CA836 EDGE FAIL','result=FAIL') if s in text]
    if stopped:errors.append(stopped)
    passed=code==0 and not errors and 'CA836 EDGE_RESULT' in text
    report={'issue':836,'passed':passed,'command':command,'exit_code':code,'errors':errors,'checks':[s for s in text.splitlines() if s.startswith('CA836 EDGE')],'sha256':{str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in packages},'engine_sha256':hashlib.sha256(engine.read_bytes()).hexdigest(),'loaded_save_sha256':hashlib.sha256(args.load.read_bytes()).hexdigest() if args.load else None,'qualification':'Frozen fixture bodies; force high-density query only during each synchronous check, restore population flag immediately. Original CanSee predicate is the independent reference for actual Candidate selection. Not campaign acceptance.'}
    (out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps({'passed':passed,'errors':errors,'checks':report['checks']}))
    raise SystemExit(not passed)

if __name__=='__main__':main()

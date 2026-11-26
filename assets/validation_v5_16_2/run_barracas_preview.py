from pathlib import Path
import argparse,json,subprocess,time,zipfile

root=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,required=True);args=parser.parse_args();out=args.output.resolve()
d=json.loads((root/'assets/barracas_redesign/LAYOUT.json').read_text())
def centre(poly):return [sum(p[i] for p in poly)/len(poly) for i in (0,1)]
civic=next(b for b in d['buildings'] if b.get('civic'));a,b,c,f=civic['bounds']
views=[{'name':'plaza','point':centre(d['plazas'][0]['polygon'])+[0],'angle':180,'pitch':0},
       {'name':'municipality','point':[c+256,(b+f)/2,0],'angle':180,'pitch':0},
       {'name':'centre','point':d['streets'][0]['points'][2]+[0],'angle':270,'pitch':0},
       {'name':'rail','point':d['railway']['points'][0]+[0],'angle':270,'pitch':0}]
audit=json.loads((out/'routes.json').read_text())
source='class CA454CityFit : Actor { Default { +NOINTERACTION +NOGRAVITY } States { Spawn: TNT1 A -1; Stop; } }\n'
source+='class CA454CityPreview : EventHandler { static vector3 Target(int i){ switch(i){'
for i,t in enumerate(audit['targets']):source+=f'case {i}:return ({t["point"][0]},{t["point"][1]},0);'
source+='}return (0,0,0);}'
source+='void Audit(){int failures=0;let probe=Actor.Spawn("CA454CityFit",Target(0),NO_REPLACE);'
source+=f'probe.A_SetSize({audit["radius"]},{audit["height"]});for(int i=0;i<{len(audit["targets"])};i++){{vector3 p=Target(i);probe.SetOrigin(p,false);probe.FindFloorCeiling();FCheckPosition fit;bool ok=probe.CheckPosition(p.XY,false,fit) && fit.floorz>=0 && fit.floorz<=8 && fit.ceilingz-fit.floorz>=probe.Height;if(!ok){{failures++;Console.Printf("CA454 CITY FIT FAIL index=%d pos=(%.1f,%.1f) floor=%.1f ceiling=%.1f",i,p.X,p.Y,fit.floorz,fit.ceilingz);}}}}'
source+=f'probe.Destroy();Console.Printf("CA454 CITY FIT total={len(audit["targets"])} failures=%d",failures);}}'
source+='override void NetworkProcess(ConsoleEvent e){if(e.Name=="ca454city_routes"){Audit();return;}let user=players[0].mo;if(user==null)return;'
for i,v in enumerate(views):
 source+=f'if(e.Name=="ca454city_{i}"){{user.bInvulnerable=true;user.SetOrigin(({",".join(map(str,v["point"]))}),false);user.FindFloorCeiling();user.SetOrigin((user.Pos.X,user.Pos.Y,user.FloorZ),false);user.Angle={v["angle"]};user.Pitch={v["pitch"]};user.Vel=(0,0,0);Console.Printf("CA454 CITY VIEW {v["name"]} floor=%.1f ceiling=%.1f",user.FloorZ,user.CeilingZ);}}'
source+='}}'
fixture=out/'camera.pk3'
with zipfile.ZipFile(fixture,'w') as z:
 for name,value in {'ZSCRIPT':'version "4.14.2"\n'+source,'MAPINFO':'gameinfo { AddEventHandlers="CA454CityPreview" }'}.items():
  z.writestr(zipfile.ZipInfo(name,(2026,11,12,0,0,0)),value)
(out/'isolated.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n')
(out/'commands.cfg').write_text('wait 140; netevent ca454city_routes; wait 5; '+'; '.join(f'netevent ca454city_{i}; wait 35; screenshot {v["name"]}.png' for i,v in enumerate(views))+'; wait 10; quit\n')
engine=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe');iwad=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
command=[str(engine),'-noautoload','-iwad',str(iwad),'-file',str(root/'build/v516/issue454-final-map02.pk3'),str(out/'preview.pk3'),str(fixture),'-config',str(out/'isolated.ini'),'-savedir',str(out),'-window','-width','1280','-height','720','+logfile',str(out/'engine.log'),'+map',d['preview_map'],'+exec',str(out/'commands.cfg')]
startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
with (out/'process.log').open('wb') as log:
 process=subprocess.Popen(command,cwd=out,stdout=log,stderr=log,startupinfo=startup)
 try:code=process.wait(timeout=120)
 except subprocess.TimeoutExpired:process.terminate();process.wait(timeout=10);raise
text=(out/'engine.log').read_text(errors='replace');errors=[s for s in ['Script error','Execution could not continue','VM execution aborted','Unknown type','CA454 CITY FIT FAIL'] if s in text]
clearance_passed=f'CA454 CITY FIT total={len(audit["targets"])} failures=0' in text
report={'issue':454,'scope':'Isolated architectural preview only, no production map or author acceptance.','views':views,'exit_code':code,'errors':errors,'clearance_targets':len(audit['targets']),'clearance_passed':clearance_passed,'captures':[v['name'] for v in views if (out/(v['name']+'.png')).exists()]}
(out/'native-results.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report))
assert code==0 and not errors and clearance_passed and len(report['captures'])==len(views)

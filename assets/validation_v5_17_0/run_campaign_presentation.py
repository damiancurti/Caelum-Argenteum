"""Observe one modular visual alongside the unchanged approved campaign scenes.

The extra noninteractive figure is a diagnostic render object. It is not an NPC
conversion, adds no combatant, and does not establish an all-model siege budget.
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

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['runtime','presentation-layer','output']:parser.add_argument('--'+name,type=Path,required=True)
    args=parser.parse_args();runtime=args.runtime.resolve(strict=True);out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    with zipfile.ZipFile(runtime) as package:
        definition=package.read('caelum/data/domingo_modules.modeldef').replace(b'CaelumDomingoPilotBody',b'CA458CampaignFigure')
    report={'issue':458,'scope':__doc__.strip(),'runtime_sha256':hashlib.sha256(runtime.read_bytes()).hexdigest(),'runs':[]}
    for label,mapname,flags in [('mansion','MAP01',[]),('sewer','MAP02',[]),('city-ground','MAP03',['--ground']),('siege','MAP03',['--siege'])]:
        existing=subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).decode(errors='replace')
        if '"gzdoom.exe"' in existing.lower():raise SystemExit('Another native engine is running.')
        tick=3601 if label=='siege' else 351
        source='''class CA458CampaignFigure : CaelumDomingoPilotFrames
{Default {+NOINTERACTION +NOGRAVITY +NOBLOCKMAP}}
class CA458CampaignPresentation : EventHandler
{
    int Age;Actor Figure;
    override void WorldTick()
    {
        Age++;if(Age!=START)return;
        let user=players[0].mo;if(user==null)return;
        vector3 point=user.Pos+(Cos(user.Angle)*64,Sin(user.Angle)*64,0);
        Figure=Actor.Spawn('CA458CampaignFigure',point,NO_REPLACE);
        Figure.Angle=user.Angle+180;Figure.Scale=user.Scale;
        Console.Printf("CA458 FIGURE one noninteractive modular figure pos=(%.3f,%.3f,%.3f) scale=(%.4f,%.4f)",Figure.Pos.X,Figure.Pos.Y,Figure.Pos.Z,Figure.Scale.X,Figure.Scale.Y);
    }
}'''.replace('START',str(tick))
        overlay=out/(label+'.pk3')
        with zipfile.ZipFile(overlay,'w') as package:
            for name,blob in {'ZSCRIPT':('version "4.14.2"\n'+source).encode(),'MODELDEF':definition,
                'MAPINFO':b'gameinfo { AddEventHandlers="CA458CampaignPresentation" }\n'}.items():
                package.writestr(zipfile.ZipInfo(name,(2026,11,13,0,0,0)),blob)
        command=[sys.executable,str(ROOT/'assets/validation_v5_16_2/run_barracas_presentation.py'),'--runtime',str(runtime),'--presentation-layer',str(args.presentation_layer.resolve()),'--players','1','--map',mapname,'--overlay',str(overlay),*flags]
        print('Starting '+label,flush=True)
        result=subprocess.run(command,capture_output=True);(out/(label+'-runner.log')).write_bytes(result.stdout+result.stderr)
        match=re.search(r'Campaign peers started:\s*(.+)',result.stdout.decode(errors='replace'))
        folder=Path(match[1].strip()) if match else None
        entry={'label':label,'directory':str(folder) if folder else None,'runner_exit':result.returncode,'passed':False}
        if folder and result.returncode==0:
            native=json.loads((folder/'results.json').read_text());entry['native_passed']=native['passed']
            analysis=subprocess.run([sys.executable,str(ROOT/'assets/validation_v5_12_7/analyze_vulkan_presents.py'),str(folder)],capture_output=True)
            (out/(label+'-analysis.log')).write_bytes(analysis.stdout+analysis.stderr)
            entry['passed']=native['passed'] and analysis.returncode==0
            if analysis.returncode==0:entry['presentation']=json.loads((folder/'presentation.json').read_text())
        report['runs'].append(entry);(out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n')
        print(json.dumps(entry),flush=True)
        if not entry['passed']:raise SystemExit(1)

if __name__=='__main__':main()

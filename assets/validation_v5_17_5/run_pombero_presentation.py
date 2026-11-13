"""Measure one 700-tic sprite/model pair for a real Pombero; no campaign or crowd budget."""
from pathlib import Path
import argparse
import json
import os
import re
import subprocess
import sys
import time
import zipfile
from run_pombero import ROOT, fixture as build, digest, ENGINE, IWAD

sys.path.insert(0,str(ROOT/'assets/validation_v5_12_7'))
from analyze_vulkan_presents import inspect, summarize

BENCH='''class CA461Bench : EventHandler
{
    int Age; double Previous; Array<double> Tics;
    override bool InputProcess(InputEvent e) { return true; }
    override void WorldTick()
    {
        Age++;
        if(Age==175) Console.Printf("CA461 BEGIN");
        if(Age<175 || Age>875) return;
        double now=MSTimeF(); if(Previous>0) Tics.Push(now-Previous); Previous=now;
        if(Age==875)
        {
            Console.Printf("CA461 END");
            for(int i=0;i<Tics.Size();i++) Console.Printf("CA461 TIC %.6f",Tics[i]);
            let gallery=CA461Events(EventHandler.Find('CA461Events'));
            Console.Printf("CA461 COMPLETE subjects=%d samples=%d", gallery==null ? 0 : (gallery.Subject==null ? 0 : 1),Tics.Size());
        }
    }
}'''


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['baseline','runtime','presentation-layer','output']:parser.add_argument('--'+name,type=Path,required=True)
    args=parser.parse_args();baseline=args.baseline.resolve(strict=True);runtime=args.runtime.resolve(strict=True);layer=args.presentation_layer.resolve(strict=True)
    if b'"gzdoom.exe"' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).lower():parser.error('Another native engine is running.')
    out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    report=dict(issue=461,scope=__doc__,baseline_sha256=digest(baseline),runtime_sha256=digest(runtime),
                engine_sha256=digest(ENGINE),layer_sha256=digest(layer/'ca_presentation.dll'),runs=[])
    for kind in ['sprite','model']:
        folder=out/kind;folder.mkdir();fixture,config=build(folder)
        bench=folder/'bench.pk3'
        with zipfile.ZipFile(bench,'w') as archive:
            archive.writestr(zipfile.ZipInfo('ZSCRIPT',(2026,11,13,0,0,0)),('version "4.14.2"\n'+BENCH).encode())
            archive.writestr(zipfile.ZipInfo('MAPINFO',(2026,11,13,0,0,0)),b'gameinfo { AddEventHandlers="CA461Bench" }\n')
        (folder/'session.ini').write_text('[LastRun]\nVersion=225\n[GlobalSettings]\nvid_preferbackend=1\nvid_fullscreen=false\nvid_defwidth=1280\nvid_defheight=720\nwin_w=1296\nwin_h=759\nvid_vsync=false\nvid_maxfps=0\ncl_capfps=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nlanguage=enu\n')
        (folder/'commands.cfg').write_text('screenblocks 12; crosshair 0; con_notifytime 0; wait 140; netevent ca461_prepare; wait 20; netevent ca461_view 0 0; wait 740; screenshot scene.png; wait 10; quit\n')
        env=os.environ.copy();env.update(VK_LAYER_PATH=str(layer),VK_INSTANCE_LAYERS='VK_LAYER_CA_presentation',CA_PRESENT_TRACE=str(folder/'presents.csv'))
        command=[str(ENGINE),'-noautoload','-nomouse','-iwad',str(IWAD),'-file',str(baseline if kind=='sprite' else runtime),str(fixture),str(bench),'-config',str(folder/'session.ini'),'-savedir',str(folder),'-window','+logfile',str(folder/'engine.log'),'+map','CA455V','+exec',str(folder/'commands.cfg')]
        startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
        markers={};offset=0;deadline=time.monotonic()+180
        with (folder/'process.log').open('wb') as stream:
            process=subprocess.Popen(command,cwd=folder,env=env,startupinfo=startup,stdout=stream,stderr=stream)
            while process.poll() is None and time.monotonic()<deadline:
                logpath=folder/'engine.log';text=''
                if logpath.exists():
                    with logpath.open('rb') as reader:reader.seek(offset);text=reader.read().decode(errors='replace');offset=reader.tell()
                    for marker in ['BEGIN','END']:
                        if 'CA461 '+marker in text:markers[marker]=time.perf_counter()*1000
                if any(token in text for token in ['Script error','Execution could not continue','VM execution aborted']):break
                time.sleep(.1)
            if process.poll() is None:process.terminate()
            code=process.wait(timeout=10)
        logpath=folder/'engine.log';log=logpath.read_text(errors='replace') if logpath.exists() else ''
        errors=[line for line in log.splitlines() if any(token in line for token in ['Script error','Execution could not continue','VM execution aborted','Unknown texture','Unable to load model','Unknown command'])]
        samples=[float(value) for value in re.findall(r'CA461 TIC ([\d.]+)',log)]
        result=dict(kind=kind,pid=process.pid,exit_code=code,errors=errors,markers_qpc_ms=markers,fixture_sha256=digest(fixture),bench_sha256=digest(bench),
                    passed=code==0 and not errors and len(samples)==700 and set(markers)=={'BEGIN','END'} and 'CA461 COMPLETE subjects=1 samples=700' in log)
        if result['passed']:
            result['simulation']=summarize(samples);result['presentation']=inspect(folder/'presents.csv',process.pid,markers['BEGIN'],markers['END'])
        report['runs'].append(result);(out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
        print(json.dumps(result),flush=True)
        if not result['passed']:raise SystemExit(1)


if __name__=='__main__':main()

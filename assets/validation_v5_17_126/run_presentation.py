"""Exercise native credit/font presentation in disposable ES/EN profiles."""
from pathlib import Path
import argparse,hashlib,json,re,subprocess,time,zipfile
from audit_presentation import locale_probe
ROOT=Path(__file__).resolve().parents[2]
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runtime',type=Path,default=ROOT/'build/issue464-review01.pk3')
    p.add_argument('--overlay',type=Path)
    p.add_argument('--output',type=Path,required=True)
    p.add_argument('--quick',action='store_true')
    a=p.parse_args();out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    fixture=out/'probe.pk3'
    with zipfile.ZipFile(fixture,'w') as z:
        for n,b in {'ZSCRIPT':b'version "4.14.2"\n#include "locale.zs"\n#include "probe.zs"\n','locale.zs':locale_probe(),'probe.zs':Path(__file__).with_name('presentation_probe.zs').read_bytes(),'MAPINFO':b'gameinfo { AddEventHandlers="CA465Probe" }\n'}.items():
            z.writestr(zipfile.ZipInfo(n,(2026,11,26,0,0,0)),b)
    report={'issue':465,'runtime_sha256':hashlib.sha256(a.runtime.read_bytes()).hexdigest(),'phases':[]}
    if a.overlay:report['overlay_sha256']=hashlib.sha256(a.overlay.read_bytes()).hexdigest()
    cases=[(w,h,lang,0) for w,h in [(640,400),(1280,720),(1520,825),(1920,1080)] for lang in ['en','es']]
    cases += [(640,400,'es',4),(1280,720,'es',2),(1920,1080,'en',3)]
    if a.quick:cases=[(1280,720,'es',0)]
    for w,h,lang,scale in cases:
        label=f'{w}x{h}-{lang}-scale{scale}';case=out/label;case.mkdir()
        (case/'session.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nwin_w='+str(w+16)+'\nwin_h='+str(h+39)+'\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage='+lang+'\n',encoding='utf8')
        (case/'commands.cfg').write_text('uiscale '+str(scale)+'; wait 105; event ca465_open; wait 5; event ca465_test '+str(int(lang=='es'))+' '+str(w)+' '+str(h)+'; wait 5; screenshot credits.png; wait 3; event ca465_main; wait 5; screenshot main.png; event ca465_done; wait 3; quit\n')
        # Windows clamps oversized decorated windows; use the native full-screen
        # mode for 1920x1080 and assert the actual client size in the probe.
        if w==1920:
            cfg=case/'session.ini';cfg.write_text(cfg.read_text().replace('vid_fullscreen=false','vid_fullscreen=true'))
        command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(a.runtime.resolve())]+([str(a.overlay.resolve())] if a.overlay else [])+[str(fixture),'-config',str(case/'session.ini'),'-savedir',str(case),'-fullscreen' if w==1920 else '-window','-width',str(w),'-height',str(h),'+logfile',str(case/'native.log'),'+exec',str(case/'commands.cfg')]
        (case/'command.json').write_text(json.dumps(command,indent=2)+'\n')
        startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=4
        with (case/'stdout.txt').open('wb') as stream:
            process=subprocess.Popen(command,cwd=case,startupinfo=startup,stdout=stream,stderr=stream);deadline=time.monotonic()+120
            while process.poll() is None:
                log=(case/'stdout.txt').read_text(errors='replace')
                if any(x in log for x in ['Script error','Execution could not continue','VM execution aborted','already has defaults']) or time.monotonic()>deadline:
                    process.terminate();process.wait(timeout=10);break
                time.sleep(1)
        log=(case/'native.log').read_text(errors='replace') if (case/'native.log').exists() else (case/'stdout.txt').read_text(errors='replace')
        counts=re.findall(r'CA465 RESULT passed=(\d+) failed=(\d+)',log)
        phase={'name':label,'exit':process.returncode,'counts':counts,'passed':process.returncode==0 and bool(counts) and all(int(f)==0 for _,f in counts)}
        report['phases'].append(phase);(out/'SUMMARY.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(phase),flush=True)
        if not phase['passed']:raise SystemExit('Inspect '+str(case))

if __name__=='__main__':main()

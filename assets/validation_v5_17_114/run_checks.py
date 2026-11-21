"""Run original surface-index equivalence, lookup timings and native save reversal."""
from pathlib import Path
import argparse,hashlib,json,re,shutil,subprocess,time,zipfile
ROOT=Path(__file__).resolve().parents[2]
FIXTURE=Path(__file__).with_name('index_checks871.zs')
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--runtime',type=Path,required=True)
p.add_argument('--reference-runtime',type=Path,required=True)
p.add_argument('--candidate',type=Path)
p.add_argument('--load',type=Path)
p.add_argument('--event',choices=['check','seed','bench'],default='check')
p.add_argument('--timeout',type=int,default=120)
p.add_argument('--fixture',type=Path,default=FIXTURE)
p.add_argument('--interpret',action='store_true')
p.add_argument('--adaptive',action='store_true')
p.add_argument('--keys',type=Path,default=Path(__file__).with_name('evidence')/'probes/index01/distribution.json')
p.add_argument('--output',type=Path,required=True)
a=p.parse_args();out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
assert 'gzdoom.exe' not in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH'],text=True,errors='replace').lower()
with zipfile.ZipFile(a.reference_runtime) as z:
    source=z.read('caelum/survival/CaelumContaminationSurface.zs').decode('utf-8').replace('\r\n','\n')
start=source.index('class CaelumContaminationMap : Object play');end=source.index('\nclass CaelumContaminationSurfaces :',start)
reference=source[start:end].replace('class CaelumContaminationMap','class CA871ReferenceMap',1)
keys=json.loads(a.keys.read_text(encoding='utf-8'))['keys']
assert len(keys)==62253 and [r[0] for r in keys]==list(range(len(keys)))
key_data=('\n'.join(' '.join(map(str,row[1:])) for row in keys)+'\n').encode()
fixture=a.fixture.read_bytes().replace(b'__ADAPTIVE__',b'1' if a.adaptive else b'0')
files={'reference.zs':reference.encode(),'checks.zs':fixture,'index_keys.txt':key_data,
    'ZSCRIPT':b'version "4.14.2"\n#include "reference.zs"\n#include "checks.zs"\n',
    'MAPINFO':b'gameinfo { AddEventHandlers="CA871IndexChecks" }\nmap MAP01 "Surface index checks" {}\n',
    'maps/MAP01.wad':(ROOT/'assets/validation_5826/away.wad').read_bytes()}
checks=out/'checks.pk3'
with zipfile.ZipFile(checks,'x') as z:
    for name,data in sorted(files.items()):z.writestr(zipfile.ZipInfo(name,(2026,11,21,0,0,0)),data)
for name,data in files.items():
    if name.endswith('.zs'):(out/name).write_bytes(data)
ini='[GlobalSettings]\nvid_preferbackend=1\nvid_fullscreen=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\nsnd_mastervolume=0.05\ni_soundinbackground=true\nvid_maxfps=60\nvid_vsync=false\nvid_defwidth=1280\nvid_defheight=720\nwin_w=1296\nwin_h=759\ncon_notifytime=0\nuse_mouse=false\nlanguage=enu\n'
if a.interpret:ini+='vm_jit=false\nvm_jit_aot=false\n'
(out/'session.ini').write_text(ini,encoding='utf-8',newline='\n')
(out/'commands.cfg').write_text(f'echo CA871_COMMANDS_START; wait 105; netevent ca871_{a.event}; wait 35; save surface-index.zds; wait 70; quit\n',encoding='utf-8',newline='\n')
engine=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
iwad=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
packages=[a.runtime.resolve()]+([a.candidate.resolve()] if a.candidate else [])+[checks]
launch=['+map','MAP01']
if a.load:shutil.copyfile(a.load,out/'input.zds');launch=['-loadgame','input.zds']
command=[str(engine),'-noautoload','-nomouse','-iwad',str(iwad),'-file',*map(str,packages),'-config',str(out/'session.ini'),'-savedir',str(out),'-window','-width','1280','-height','720','+logfile',str(out/'engine.log'),*launch,'+exec',str(out/'commands.cfg')]
startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
markers=('Bad type for constant', 'Script error','VM execution aborted','Execution could not continue','DIED WITH FATAL ERROR')
timed_out=False
with (out/'process.log').open('wb') as log:
    proc=subprocess.Popen(command,cwd=out,stdout=log,stderr=log,startupinfo=startup);deadline=time.monotonic()+a.timeout
    while proc.poll() is None:
        f=out/'engine.log';sample=f.read_text(encoding='utf-8',errors='replace') if f.exists() else ''
        timed_out=time.monotonic()>deadline
        if any(s in sample for s in markers) or timed_out:proc.terminate();break
        time.sleep(.25)
    code=proc.wait(timeout=15)
log=(out/'engine.log').read_text(encoding='utf-8',errors='replace')
result=re.search(r'CA871 RESULT checks=(\d+) errors=(\d+)',log)
errors=[line for line in log.splitlines() if any(s in line for s in markers) or line.startswith('CA871 FAIL')]
if not (out/'surface-index.zds').is_file():errors.append('Expected native save is missing; successful assertions alone do not establish persistence.')
if timed_out:errors.append(f'Native diagnostic timed out before completion ({a.timeout} seconds); native crash dialogs may not appear in engine.log.')
bench=[dict(tiles=int(n),calls=int(calls),original_ms=float(o),candidate_ms=float(c),buckets=int(b)) for n,calls,o,c,b in re.findall(r'CA871 BENCH tiles=(\d+) calls=(\d+) original_ms=([\d.]+) candidate_ms=([\d.]+) buckets=(\d+)',log)]
small=[dict(tiles=int(n),calls=int(calls),original_ms=float(o),candidate_ms=float(c),buckets=int(b)) for n,calls,o,c,b in re.findall(r'CA871 SMALL tiles=(\d+) calls=(\d+) original_ms=([\d.]+) candidate_ms=([\d.]+) buckets=(\d+)',log)]
growth=[dict(tiles=int(n),before=int(b),after=int(a),ms=float(t)) for n,b,a,t in re.findall(r'CA871 GROW tiles=(\d+) before=(\d+) after=(\d+) ms=([\d.]+)',log)]
first_find=[dict(label=l,tiles=int(n),before=int(b),after=int(a),ms=float(t)) for l,n,b,a,t in re.findall(r'CA871 FIRST_FIND label=(\w+) tiles=(\d+) before=(\d+) after=(\d+) ms=([\d.]+)',log)]
passed=code==0 and not errors and result is not None and int(result[2])==0 and len(bench)==(1 if a.event in ('check','bench') else 0) and len(small)==(3 if a.event in ('check','bench') else 0) and (out/'surface-index.zds').is_file()

sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
report=dict(issue=871,event=a.event,adaptive=a.adaptive,interpret=a.interpret,passed=passed,exit_code=code,checks=int(result[1]) if result else 0,errors=errors,benchmark=bench,small_benchmark=small,growth=growth,first_find=first_find,
    runtime_sha256=sha(a.runtime),reference_runtime_sha256=sha(a.reference_runtime),candidate_sha256=sha(a.candidate) if a.candidate else None,
    fixture_sha256=hashlib.sha256(fixture).hexdigest(),key_data_sha256=hashlib.sha256(key_data).hexdigest(),checks_sha256=sha(checks),engine_sha256=sha(engine),input_save_sha256=sha(a.load) if a.load else None,
    output_save_sha256=sha(out/'surface-index.zds') if (out/'surface-index.zds').exists() else None,
    qualification='Private original-map-class oracle on62253 actual current-map tile keys, plus signed/absent/duplicate-key and identity tests. Native saved objects preserve tile references and all authoritative tile/map fields; only derived bucket/Next links may change. Alternating repeated lookup timings are not whole-scene frame rates.')
(out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({k:report[k] for k in ('passed','checks','errors','benchmark')}));raise SystemExit(not passed)

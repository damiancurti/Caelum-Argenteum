from pathlib import Path
import hashlib, json, subprocess, zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue147'
BASE='f7c4a0dd'
def package(path, members):
 with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
  for name,data in sorted(members.items()): z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
 return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 if 'gzdoom.exe' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],text=True).lower(): raise SystemExit('Finish the native run before replacing packages.')
 OUT.mkdir(exist_ok=True)
 if not (OUT/'baseline.pk3').exists(): subprocess.run(['git','archive','--format=zip',f'--output={OUT / "baseline.pk3"}',BASE+':src'],cwd=ROOT,check=True)
 manifest={'baseline':hashlib.sha256((OUT/'baseline.pk3').read_bytes()).hexdigest()}
 manifest['production']=package(OUT/'production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})
 for source in sorted(HERE.glob('*.zs')):
  members={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n','checks.zs':source.read_bytes(),
    'CVARINFO':b'server int ca147_stage=0;\n',
    'MAPINFO':f'GameInfo {{ AddEventHandlers="CA147{source.stem.title()}" }}\n'.encode()}
  manifest[source.stem]=package(OUT/(source.stem+'.pk3'),members)
 for alias_name, runtime_name in [('migration-runtime','baseline.pk3'),('current-runtime','production.pk3')]:
  alias=OUT/alias_name;alias.mkdir(exist_ok=True)
  (alias/runtime_name).write_bytes((OUT/'production.pk3').read_bytes())
  package(alias/'flow.pk3',{'ZSCRIPT':b'version "4.14"\n#include "flow.zs"\n#include "probe.zs"\n',
   'flow.zs':(HERE/'flow.zs').read_bytes(),'probe.zs':(HERE/'probe.zs').read_bytes(),
   'CVARINFO':b'server int ca147_stage=0;\n','MAPINFO':b'GameInfo { AddEventHandlers="CA147Flow", "CA147Probe" }\n'})
 for cfg in HERE.glob('*.cfg'): (OUT/cfg.name).write_bytes(cfg.read_bytes())
 (OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
 print('Prepared #147 packages:',', '.join(manifest))
if __name__=='__main__':main()

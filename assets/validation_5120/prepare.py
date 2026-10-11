from pathlib import Path
import hashlib, json, subprocess, zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue173'
BASE='1c620037'
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
    'CVARINFO':b'server int ca173_stage=0;\n',
    'MAPINFO':f'GameInfo {{ AddEventHandlers="CA173{source.stem.title()}" }}\n'.encode()}
  if source.stem=='migration':
   members['city.zs']=(HERE/'city.zs').read_bytes();members['legacy.zs']=(HERE/'legacy.zs').read_bytes()
   members['ZSCRIPT']=b'version "4.14"\n#include "legacy.zs"\n#include "city.zs"\n#include "checks.zs"\n'
  manifest[source.stem]=package(OUT/(source.stem+'.pk3'),members)
 alias=OUT/'migration-runtime';alias.mkdir(exist_ok=True)
 (alias/'baseline.pk3').write_bytes((OUT/'production.pk3').read_bytes())
 (alias/'legacy.pk3').write_bytes((OUT/'migration.pk3').read_bytes())
 for cfg in HERE.glob('*.cfg'): (OUT/cfg.name).write_bytes(cfg.read_bytes())
 (OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
 print('Prepared #173 packages:',', '.join(manifest))
if __name__=='__main__':main()

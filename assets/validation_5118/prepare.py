from pathlib import Path
import hashlib, json, subprocess, zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue164'
BASE='6cae68bddcef3cdc6b32ac6208e5223747c3ad81'
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
    'CVARINFO':b'server int ca164_stage=0;\n',
    'MAPINFO':f'GameInfo {{ AddEventHandlers="CA164{source.stem.title()}" }}\n'.encode()}
  if source.stem=='route':
   members['MAPINFO']=b'GameInfo { AddEventHandlers="CA164Route", "CA164RouteObserver" }\n'
  if source.stem=='ui':
   members['route.zs']=(HERE/'route.zs').read_bytes()
   members['ZSCRIPT']=b'version "4.14"\n#include "route.zs"\n#include "checks.zs"\n'
  if source.stem=='optional':
   members['legacy.zs']=(HERE/'legacy.zs').read_bytes()
   members['route.zs']=(HERE/'route.zs').read_bytes()
   members['ZSCRIPT']=b'version "4.14"\n#include "legacy.zs"\n#include "route.zs"\n#include "checks.zs"\n'
   members['MAPINFO']=b'GameInfo { AddEventHandlers="CA164Optional" }\n'
  if source.stem=='migration':
   members['legacy.zs']=(HERE/'legacy.zs').read_bytes()
   members['ZSCRIPT']=b'version "4.14"\n#include "legacy.zs"\n#include "checks.zs"\n'
   members['MAPINFO']=b'GameInfo { AddEventHandlers="CA164Legacy", "CA164Migration" }\n'
  manifest[source.stem]=package(OUT/(source.stem+'.pk3'),members)
 for directory,runtime,fixture in [('migration-runtime','baseline','legacy'),('optional-runtime','production','route'),('ui-runtime','production','route')]:
  dest=OUT/directory;dest.mkdir(exist_ok=True)
  (dest/(runtime+'.pk3')).write_bytes((OUT/'production.pk3').read_bytes())
  source='migration' if directory=='migration-runtime' else 'ui' if directory=='ui-runtime' else 'optional'
  (dest/(fixture+'.pk3')).write_bytes((OUT/(source+'.pk3')).read_bytes())
 for cfg in HERE.glob('*.cfg'): (OUT/cfg.name).write_bytes(cfg.read_bytes())
 (OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
 print('Prepared #164 packages:',', '.join(manifest))
if __name__=='__main__':main()

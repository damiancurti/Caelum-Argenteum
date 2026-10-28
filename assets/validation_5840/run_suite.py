"""Run focused final-package checks serially; preserve every diagnostic run."""
from pathlib import Path
import argparse,subprocess
R=Path(__file__).resolve().parents[2];H=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--runtime',default='final40a');p.add_argument('--prefix',default='releasea');a=p.parse_args()
cases=[(x,[]) for x in ['catalogue','craft','trade','items','legacy','seed']]
cases += [(x,['-LoadGame','dining-current.zds']) for x in ['resume','loadedtrade']]
cases += [(x,[]) for x in ['hub','nestedhub','input','weather','exposure','studyhub']]
cases += [('priorload',['-Addon','legacy-checks.pk3','-LoadGame','dining-prior39.zds'])]
cases += [(f'{kind}{n}',['-StartMap','CDIN410','-Language','esp']) for kind in ['view','icon'] for n in range(4)]
for case,extra in cases:
 print('RUN',case,flush=True)
 subprocess.run(['powershell','-NoProfile','-ExecutionPolicy','Bypass','-File',str(H/'run_native.ps1'),'-Label',a.prefix+'-'+case,'-Runtime',a.runtime,'-Script',case,'-Checks',*extra],cwd=R,check=True)
print('All selected native runs completed.',flush=True)

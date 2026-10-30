"""Package isolated wake tests with the diagnostic candidate overlay."""
from pathlib import Path
import importlib.util
import zipfile
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'build/issue433'
spec=importlib.util.spec_from_file_location('room',ROOT/'assets/validation_5103/prepare.py')
prior=importlib.util.module_from_spec(spec);spec.loader.exec_module(prior)
with zipfile.ZipFile(OUT/'candidate.pk3') as source:files={n:source.read(n) for n in source.namelist()}
files.update({'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
 'checks.zs':(Path(__file__).parent/'checks.zs').read_bytes(),'maps/CA433A.wad':prior.room(),
 'MAPINFO':b'GameInfo { AddEventHandlers="CA433Checks" }\nmap CA433A "Distant evaluation" { }\n'})
with zipfile.ZipFile(OUT/'checks.pk3','w',zipfile.ZIP_STORED) as z:
 for name,data in sorted(files.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
print('Prepared native wake checks.')

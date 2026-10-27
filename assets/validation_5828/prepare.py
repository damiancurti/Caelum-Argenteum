"""Create deterministic private weather-history probes; never alter campaign maps."""
from pathlib import Path
import importlib.util
import sys
import zipfile

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue502-weather'
WORK.mkdir(parents=True, exist_ok=True)

def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result

room = module('placement', ROOT/'assets/validation_588/prepare.py').room()
room = room.replace('textureceiling="CMST02"', 'textureceiling="F_SKY1"')
room = room.replace('sector {', 'sector { user_ca_contamination_class=2;')
wad = module('water', ROOT/'assets/validation_580/prepare.py').wad
members = {
    'ZSCRIPT': b'version "4.14"\n#include "checks.zs"\n',
    'checks.zs': (HERE/'checks.zs').read_bytes(),
    'MAPINFO': b'GameInfo {AddEventHandlers="CA502WeatherChecks"}\ncluster 8528 {hub}\nmap CWH502 "Weather history" {cluster=8528}\nmap CWH502B "Away" {cluster=8528}\n',
    'maps/CWH502.wad': wad(room, 'CWH502'),
    'maps/CWH502B.wad': wad(room, 'CWH502B'),
}
with zipfile.ZipFile(WORK/'checks.pk3', 'w', zipfile.ZIP_STORED) as archive:
    for name, blob in sorted(members.items()):
        archive.writestr(zipfile.ZipInfo(name, (2000,1,1,0,0,0)), blob)
legacy=WORK/'legacy'
legacy.mkdir(exist_ok=True)
members['checks.zs']=(HERE/'legacy.zs').read_bytes()
with zipfile.ZipFile(legacy/'checks.pk3', 'w', zipfile.ZIP_STORED) as archive:
    for name, blob in sorted(members.items()):
        archive.writestr(zipfile.ZipInfo(name, (2000,1,1,0,0,0)), blob)
commands = {
    'core': 'netevent ca502w_core',
    'perf': 'netevent ca502w_perf',
    'seed': 'netevent ca502w_seed; save weather-current28',
    'resume': 'netevent ca502w_resume',
    'hub': 'netevent ca502w_seed; changemap CWH502B; wait 70; netevent ca502w_away; changemap CWH502; wait 70; netevent ca502w_resume',
    'oldseed': 'netevent ca502w_oldseed; save weather-legacy27',
    'legacy': 'netevent ca502w_legacy',
    'oldcheck': 'netevent ca502w_oldcheck',
}
for name, command in commands.items():
    (WORK/(name+'.cfg')).write_text('wait 140; '+command+'; wait 5; quit\n', encoding='utf-8')
print('Prepared weather-history native probes.')

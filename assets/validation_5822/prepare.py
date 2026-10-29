"""Build private native probes; campaign MAP01 and artwork stay unchanged."""
from pathlib import Path
import importlib.util
import zipfile
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue410-cooking'
WORK.mkdir(parents=True, exist_ok=True)
def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result
room = module('placement', ROOT/'assets/validation_588/prepare.py').room()
wad = module('water', ROOT/'assets/validation_580/prepare.py').wad
base = (ROOT/'assets/validation_5814/checks.zs').read_bytes()
mapinfo = b'GameInfo { AddEventHandlers="CA410MBChecks" }\ncluster 8522 {hub}\nmap MAP01 "Mansion" {cluster=8522}\nmap CBTH410 "Away" {cluster=8522}\n'
members = {'ZSCRIPT': b'version "4.14"\n#include "checks.zs"\n',
           'checks.zs': base+b'\n'+(HERE/'checks.zs').read_bytes(), 'MAPINFO': mapinfo,
           'maps/CBTH410.wad': wad(room, 'CBTH410')}
def archive(name, contents):
    with zipfile.ZipFile(WORK/name, 'w', zipfile.ZIP_STORED) as output:
        for key, value in sorted(contents.items()):
            output.writestr(zipfile.ZipInfo(key, (2000,1,1,0,0,0)), value)
archive('bath-checks.pk3', members)
legacy = '''class CA410MBChecks : CA410FoodChecks {
 double SavedWater,SavedStamp;
 override void NetworkProcess(ConsoleEvent e){let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;Setup(u);u.CurrentHunger=100;
 let water=CaelumDomesticWater.Get(CaelumDomesticWaterData.MANSION);
 if(e.Name=='ca410mb_seed'){water.Liters=17;SavedWater=17;SavedStamp=water.Stamp;Check(water!=null,"legacy reserve seeded");}
 if(e.Name=='ca410mb_resume')Check(Near(water.Liters,Min(200,SavedWater+(water.Stamp-SavedStamp)/60)),"original version rollback retains water");
 Console.Printf("CA410F RESULT legacy passed=%d failed=%d",Passed,Failed);}}
'''
members['checks.zs'] = base+b'\n'+legacy.encode()
archive('bath-legacy.pk3', members)
for mode in ('rooms', 'shared', 'access', 'seed', 'resume'):
    command = f'wait 210; netevent ca410mb_{mode}; '
    if mode == 'seed': command += 'save ca410mb-progress; '
    (WORK/f'bath-{mode}.cfg').write_text(command+'wait 5; quit\n', encoding='utf-8')
(WORK/'bath-oldseed.cfg').write_text('wait 210; netevent ca410mb_seed; save ca410mb-legacy21; wait 5; quit\n', encoding='utf-8')
(WORK/'bath-hub.cfg').write_text('wait 35; netevent ca410mb_seed; changemap CBTH410; wait 35; netevent ca410mb_away; changemap MAP01; wait 210; netevent ca410mb_resume; netevent ca410mb_rooms; wait 5; quit\n', encoding='utf-8')
for index in range(4):
    (WORK/f'bath-view{index}.cfg').write_text(f'wait 210; netevent ca410mb_view {index} 0; wait 10; screenshot final-mansion-bath-{index}.png; wait 5; quit\n', encoding='utf-8')
for mode in (1,2):
    (WORK/f'bath-pose{mode}.cfg').write_text(f'wait 210; netevent ca410mb_view 0 {mode}; wait 10; screenshot final-mansion-bath-pose-{mode}.png; wait 5; quit\n', encoding='utf-8')
captures=['wait 210']
for index in range(4):
    for pose in (0,1,2):
        captures += [f'netevent ca410mb_view {index} {pose}', 'wait 10', f'screenshot finald-mansion-bath-{index}-{pose}.png']
(WORK/'bath-capture-finald.cfg').write_text('; '.join(captures+['wait 5','quit'])+'\n',encoding='utf-8')
controls='; '.join(line.strip() for line in (ROOT/'assets/playtest/default_controls.cfg').read_text(encoding='utf-8').splitlines() if line.strip() and not line.lstrip().startswith('//'))
for index in range(4):
    (WORK/f'bath-author-{index}.cfg').write_text(controls+f'; wait 210; netevent ca410mb_manual {index}\n',encoding='utf-8')
(WORK/'bath-manual-smoke.cfg').write_text(controls+'; wait 210; netevent ca410mb_manual 0; wait 5; quit\n',encoding='utf-8')
print('Prepared mansion bathroom probes and old-version bridge.')

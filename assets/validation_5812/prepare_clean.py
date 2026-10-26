"""Build independent equipment-cleaning tests; preserve accepted bath packages."""
from pathlib import Path
import zipfile

here = Path(__file__).resolve().parent
out = here.parents[1] / 'build/issue502-hygiene'
proof = '''class CA502CleanProof : Inventory {
CaelumEquipmentItem Item; double Remaining,Water,Soap;
Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
States {Spawn:TNT1 A -1;Stop;}}
class CA502BathProof : Inventory {
double Credit,Soap,C,Remaining,Removed,Water,Stamp;
Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
States {Spawn:TNT1 A -1;Stop;}}
'''
source = (here / 'checks.zs').read_text(encoding='utf-8')
helpers = '\n'.join((here / f).read_text(encoding='utf-8') for f in ('pose_checks.zs', 'bath_checks.zs', 'clean_checks.zs'))
source = proof + source.replace('    override void NetworkProcess(ConsoleEvent e)', helpers + '\n    override void NetworkProcess(ConsoleEvent e)')
source = source.replace("        if(e.Name=='ca502h_core')Core(u);", '''        if(e.Name=='ca_inventory_boil' && TrackH){HBoil++;return;}
        if(e.Name=='ca_bath_open' && TrackH){HBath++;return;}
        if(e.Name=='ca502h_ui_missing')Check(false,"native inventory menu available");
        else if(e.Name=='ca502h_hwater')CleanKeySetup(u,true);
        else if(e.Name=='ca502h_hgear')CleanKeySetup(u,false);
        else if(e.Name=='ca502h_hwater_verify')Check(HBoil==1 && HBath==0,"native inventory H keeps boiling on selected water");
        else if(e.Name=='ca502h_hgear_verify')Check(HBoil==0 && HBath==1 && CaelumBathSession.Find(u).Open,"native inventory H still opens bathing for other items");
        else if(e.Name=='ca502h_jgear_verify')Check(CaelumCleaningSession.Find(u)!=null && CaelumCleaningSession.Find(u).Open,"native inventory J opens equipment cleaning");
        else if(e.Name=='ca502h_clean_core')CleanCore(u);
        else if(e.Name=='ca502h_clean_sleep')CleanSleep(u);
        else if(e.Name=='ca502h_clean_repair')CleanRepair(u);
        else if(e.Name=='ca502h_clean_bag')CleanBag(u);
        else if(e.Name=='ca502h_clean_seed')CleanSeed(u);
        else if(e.Name=='ca502h_clean_load')CleanLoad(u);
        else if(e.Name=='ca502h_clean_hub')CleanLoad(u,true);
        else if(e.Name=='ca502h_clean_status')CleanStatus(u);
        else if(e.Name=='ca502h_clean_live_end')CleanLiveEnd(u);
        else if(e.Name=='ca502h_clean_manual_sleep')CleanManualSleep(u);
        else if(e.Name=='ca502h_clean_manual')CleanManual(u);
        else if(e.Name=='ca502h_clean_legacy'){Check(CaelumCleaningTask.Find(u)==null && !CaelumCleaningTask.Active(u),"pre-cleaning save creates no phantom task");Check(CaelumBathTask.Attended(u),"accepted bath save retains its active task");}
        else if(e.Name=='ca502h_core')Core(u);''')
members = {'ZSCRIPT': b'version "4.14.2"\n#include "checks.zs"\n', 'checks.zs': source.encode(), 'MAPINFO': b'GameInfo { AddEventHandlers="CA502HChecks" }\n'}
with zipfile.ZipFile(out / 'clean-checks.pk3', 'w', zipfile.ZIP_STORED) as archive:
    for name, blob in sorted(members.items()):
        archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), blob)
scripts = {
    'clean-keys': 'wait 70; netevent ca502h_hwater; event ca502h_inventory; wait 5; event ca502h_press_h; wait 5; netevent ca502h_hwater_verify; netevent ca502h_hgear; event ca502h_inventory; wait 5; event ca502h_press_h; wait 5; netevent ca502h_hgear_verify; netevent ca502h_hgear; event ca502h_inventory; wait 5; event ca502h_press_j; wait 5; netevent ca502h_jgear_verify; wait 5; quit',
    'clean-core': 'wait 70; netevent ca502h_clean_core; wait 5; quit',
    'clean-sleep': 'wait 70; netevent ca502h_clean_sleep; wait 5; quit',
    'clean-repair': 'wait 70; netevent ca502h_clean_repair; wait 5; quit',
    'clean-bag': 'wait 70; netevent ca502h_clean_bag; wait 5; quit',
    'clean-save': 'wait 70; netevent ca502h_clean_seed; save ca502h-clean; wait 5; quit',
    'clean-live': 'wait 70; netevent ca502h_clean_seed; wait 90; netevent ca502h_clean_live_end; wait 5; quit',
    'clean-load': 'wait 1; netevent ca502h_clean_load; wait 5; quit',
    'clean-hub': 'wait 1; changemap CAH001; wait 70; netevent ca502h_clean_hub; changemap CAH000; wait 70; netevent ca502h_clean_hub; wait 5; quit',
    'clean-legacy': 'wait 1; netevent ca502h_clean_legacy; wait 5; quit',
    'clean-manual': 'wait 70; netevent ca502h_clean_manual; bind F1 "netevent ca502h_clean_manual"; bind F2 "netevent ca_clean_open"; bind F3 "netevent ca502h_clean_status"; bind F4 "netevent ca502h_clean_manual_sleep"; bind F6 toggleconsole',
    'clean-capture': 'wait 70; netevent ca502h_clean_manual; netevent ca_clean_open; wait 10; screenshot clean-menu.png; netevent ca_clean_action 1; wait 5; screenshot clean-live.png; wait 5; quit',
}
for name, script in scripts.items():
    (out / (name + '.cfg')).write_text(script + '\n', encoding='utf-8', newline='\n')
print('Prepared independent equipment-cleaning addon and scripts.')

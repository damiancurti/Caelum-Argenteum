"""Keep state/contact fixtures separate from the author's severe-illness addon."""
from pathlib import Path
import zipfile

ROOT=Path(__file__).resolve().parents[3]
WORK=ROOT/'build/issue502'
HERE=Path(__file__).resolve().parent
target=WORK/'storage'
target.mkdir(exist_ok=True)
with zipfile.ZipFile(WORK/'checks.pk3') as original:
    members={n:original.read(n) for n in original.namelist()}
members['ZSCRIPT']+=b'#include "storage.zs"\n'
members['storage.zs']=(HERE/'checks.zs').read_bytes()
members['MAPINFO']=members['MAPINFO'].replace(b'CA502Checks',b'CA502StorageChecks')
with zipfile.ZipFile(target/'checks.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,blob in sorted(members.items()):
        archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
scripts={
    'core':'wait 35; netevent ca502_storage; wait 5; quit',
    'save':'wait 35; netevent ca502_storage_seed; save ca502-storage; wait 5; quit',
    'load':'wait 1; netevent ca502_storage_load; wait 5; quit',
    'hub':'wait 1; netevent ca502_storage_load; changemap CTX502B; wait 35; changemap CTX502; wait 35; netevent ca502_storage_load; wait 5; quit',
}
for name,text in scripts.items():(target/(name+'.cfg')).write_text(text+'\n',encoding='utf-8')
print('Prepared separate state/contact addon.')

# The original-save fixture contains no class introduced by #502.
template='''class CA502Legacy : EventHandler
{
    CaelumWeaponPickup SavedWeapon;
    Actor SavedSurface;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!='ca502_legacy' || e.Player<0 || e.Player>=MAXPLAYERS)return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        u.CreationWizardOpen=false;
        let illness=CaelumFoodIllness.Get(u);
        bool ok=true;
        // MODE
        Console.Printf("CA502 %s original actors and equipment",ok?"PASS":"FAIL");
        Console.Printf("CA502 LEGACY result=%s",ok?"PASS":"FAIL");
    }
}
'''
modes={
    'baseline':'''illness.Contamination=12.5;u.DerivedStats.HealthRegenerationPerSecond=0;
        SavedWeapon=CaelumWeaponPickup(Actor.Spawn('CaelumWeaponPickup',u.Pos+(100,0,0),NO_REPLACE));
        SavedSurface=Actor.Spawn('MapSpot',u.Pos+(100,32,0),NO_REPLACE);
        ok=SavedWeapon!=null && SavedSurface!=null;''',
    'bridge':'''ok=SavedWeapon!=null && SavedSurface!=null && illness.Contamination==12.5
            && SavedWeapon.ContaminationState==null && CaelumContaminationStorage.Get(SavedSurface)==null;
        let weapon=CaelumContaminationStorage.Get(SavedWeapon,true);
        let surface=CaelumContaminationStorage.Get(SavedSurface,true);
        ok=ok && weapon!=null && surface!=null && weapon.Concentration==0 && surface.Concentration==0;
        weapon.Concentration=73;surface.Concentration=61;weapon.Ensure();surface.Ensure();
        ok=ok && weapon.Concentration==73 && surface.Concentration==61;''',
    'rollback':'''ok=SavedWeapon!=null && SavedSurface!=null && illness.Contamination==12.5;''',
}
for mode,code in modes.items():
    folder=target/mode;folder.mkdir(exist_ok=True)
    legacy={n:b for n,b in members.items() if n in ['maps/CTX502.wad','maps/CTX502B.wad']}
    legacy['ZSCRIPT']=b'version "4.14"\n#include "checks.zs"\n'
    legacy['checks.zs']=template.replace('// MODE',code).encode('utf-8')
    legacy['MAPINFO']=members['MAPINFO'].replace(b'CA502StorageChecks',b'CA502Legacy')
    with zipfile.ZipFile(folder/'legacy-checks.pk3','w',zipfile.ZIP_STORED) as archive:
        for name,blob in sorted(legacy.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
(target/'legacy-seed.cfg').write_text('wait 35; netevent ca502_legacy; save ca502-storage-legacy; wait 5; quit\n',encoding='utf-8')
(target/'legacy-load.cfg').write_text('wait 1; netevent ca502_legacy; wait 5; quit\n',encoding='utf-8')

"""Build focused native fixtures without modifying the production mansion map."""
from pathlib import Path
import runpy
import zipfile
import subprocess
import sys
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue410-cooking'
runpy.run_path(str(ROOT/'assets/validation_5822/prepare.py'))
with zipfile.ZipFile(WORK/'bath-checks.pk3') as archive:
    members={name:archive.read(name) for name in archive.namelist()}
members['checks.zs']=(HERE/'checks.zs').read_bytes()
members['MAPINFO']=members['MAPINFO'].replace(b'CA410MBChecks',b'CA410WaterFurnitureChecks')
if '--overlay' in sys.argv:
    names=set(subprocess.check_output(['git','diff','--name-only','HEAD','--','src'],cwd=ROOT,text=True).splitlines())
    names.update(subprocess.check_output(['git','ls-files','--others','--exclude-standard','--','src'],cwd=ROOT,text=True).splitlines())
    for name in names:
        path=ROOT/name
        if path.name in ('ZSCRIPT','MODELDEF','TEXTURES'):continue
        if path.is_file():members[path.relative_to(ROOT/'src').as_posix()]=path.read_bytes()
with zipfile.ZipFile(WORK/'water-furniture-checks.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,data in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
legacy='''class CA410WaterFurnitureChecks : EventHandler {
 double SavedStamp;int Passed,Failed;
 override void NetworkProcess(ConsoleEvent e){let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
 if(e.Name!='ca410wf_oldseed' && e.Name!='ca410wf_oldload')return;
 u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;
 u.GetPersistentCharacterState(true).ProfileCommitted=true;
 u.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
 let water=CaelumDomesticWater.Get(CaelumDomesticWaterData.MANSION);
 if(e.Name=='ca410wf_oldseed'){water.Liters=73.123;SavedStamp=water.Stamp;Passed++;Console.Printf("CA410WF PASS original reserve seeded");}
 if(e.Name=='ca410wf_oldload'){bool ok=Abs(water.Liters-Min(200,73.123+(water.Stamp-SavedStamp)/60))<.000001;
 if(ok)Passed++;else Failed++;Console.Printf("CA410WF %s original save rollback preserves reserve",ok?"PASS":"FAIL");}
 Console.Printf("CA410WF RESULT passed=%d failed=%d",Passed,Failed);}}
'''
legacy_members={k:v for k,v in members.items() if k in ('ZSCRIPT','MAPINFO','maps/CBTH410.wad')}
legacy_members['checks.zs']=legacy.encode()
with zipfile.ZipFile(WORK/'water-furniture-legacy.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,data in sorted(legacy_members.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
prefix='wait 1; netevent ca410wf_profile; wait 210; '
commands={name:prefix+f'netevent ca410wf_{name}; wait 5; quit' for name in ('core','mansion','bath')}
commands['seed']=prefix+'netevent ca410wf_seed; wait 5; save water-furniture-progress; wait 5; quit'
commands['resume']='wait 210; netevent ca410wf_resume; wait 5; quit'
commands['legacyresume']='wait 210; netevent ca410wf_legacyresume; wait 5; quit'
commands['oldseed']='wait 210; netevent ca410wf_oldseed; wait 5; save water-furniture-legacy24; wait 5; quit'
commands['oldload']='wait 210; netevent ca410wf_oldload; wait 5; quit'
commands['locale']='wait 210; netevent ca410wf_locale; wait 5; quit'
commands['hub']=prefix+'netevent ca410wf_seed; wait 5; changemap CBTH410; wait 70; netevent ca410wf_away; wait 5; changemap MAP01; wait 210; netevent ca410wf_resume; wait 5; quit'
for kind in range(2):commands['view'+str(kind)]=prefix+f'netevent ca410wf_view {kind}; wait 70; screenshot water-furniture-view{kind}.png; wait 5; quit'
controls='; '.join(line.strip() for line in (ROOT/'assets/playtest/default_controls.cfg').read_text(encoding='utf-8').splitlines() if line.strip() and not line.lstrip().startswith('//'))
commands['author']=controls+'; '+prefix+'netevent ca410wf_author'
commands['author-smoke']=commands['author']+'; wait 70; netevent ca410wf_locale; wait 5; quit'
commands['inventory']=commands['author']+'; wait 70; netevent ca410wf_select; ca_journal_page 0; ca_journal_open true; wait 70; screenshot water-furniture-inventory.png; netevent ca_inventory_water; wait 5; netevent ca410wf_verify_action; netevent ca410wf_select 1; wait 5; netevent ca_inventory_water_deposit; wait 5; netevent ca410wf_verify_action 1; wait 5; quit'
for name,script in commands.items():(WORK/('water-furniture-'+name+'.cfg')).write_text(script+'\n',encoding='utf-8')
print('Prepared water-furniture native fixtures.')

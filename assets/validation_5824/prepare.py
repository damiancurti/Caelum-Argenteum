"""Reuse the unchanged mansion hub bridge for the wardrobe's native checks."""
from pathlib import Path
import runpy
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT/'build/issue410-cooking'
runpy.run_path(str(ROOT/'assets/validation_5822/prepare.py'))
with zipfile.ZipFile(WORK/'bath-checks.pk3') as archive:
    members = {name:archive.read(name) for name in archive.namelist()}
members['checks.zs'] = (HERE/'checks.zs').read_bytes()
members['MAPINFO'] = members['MAPINFO'].replace(b'CA410MBChecks',b'CA410WardrobeChecks')
with zipfile.ZipFile(WORK/'wardrobe-checks.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,data in sorted(members.items()):
        archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
legacy = r'''class CA410WardrobeChecks : EventHandler
{
 CaelumStashChest Wardrobe;int Passed,Failed;bool Manual;
 void Check(bool ok,String label){if(ok)Passed++;else Failed++;Console.Printf("CA410W %s %s",ok?"PASS":"FAIL",label);}
 override void NetworkProcess(ConsoleEvent e)
 {
  let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
  u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;u.CurrentHunger=100;
  u.GetPersistentCharacterState(true).ProfileCommitted=true;
  u.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
  if(e.Name=='ca410w_oldseed')
  {
   Wardrobe=CaelumStashChest(Actor.Spawn('CaelumStashChest',(-464,448,136),NO_REPLACE));Wardrobe.EnsureStorage();
   let bread=CaelumConsumableItem(Actor.Spawn('CaelumBread'));bread.Amount=2;bread.AttachToOwner(Wardrobe);
   Check(Wardrobe!=null && Wardrobe.StorageTier==CaelumContainerRules.MEDIUM,"old package seeded original chest and food");
  }
  else if(e.Name=='ca410w_oldload')
   Check(Wardrobe!=null && Wardrobe.FindInventory('CaelumBread').Amount==2,"original package rollback retains original chest contents");
  Console.Printf("CA410W RESULT passed=%d failed=%d",Passed,Failed);
 }
}'''
legacy_members=dict(members);legacy_members['checks.zs']=legacy.encode()
with zipfile.ZipFile(WORK/'wardrobe-legacy.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,data in sorted(legacy_members.items()):
        archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
commands = {
    'oldseed':'wait 210; netevent ca410w_oldseed; wait 3; save wardrobe-legacy23; wait 5; quit',
    'oldload':'wait 210; netevent ca410w_oldload; wait 5; quit',
    'legacyresume':'wait 210; netevent ca410w_legacyresume; wait 5; quit',
    'placement':'wait 1; netevent ca410w_profile; wait 210; netevent ca410w_placement; wait 5; quit',
    'core':'wait 70; netevent ca410w_prepare; wait 3; netevent ca410w_core; wait 5; quit',
    'mansion':'wait 1; netevent ca410w_profile; wait 210; netevent ca410w_mansion; wait 5; quit',
    'seed':'wait 1; netevent ca410w_profile; wait 210; netevent ca410w_seed; save wardrobe-stored; wait 5; quit',
    'carryseed':'wait 1; netevent ca410w_profile; wait 210; netevent ca410w_seed 1; save wardrobe-carried24b; wait 5; quit',
    'resume':'wait 210; netevent ca410w_resume; wait 5; quit',
    'carryresume':'wait 210; netevent ca410w_resume 1; wait 5; quit',
    'hub':'wait 1; netevent ca410w_profile; wait 210; netevent ca410w_seed; changemap CBTH410; wait 70; changemap MAP01; wait 210; netevent ca410w_resume; wait 5; quit',
    'carryhub':'wait 1; netevent ca410w_profile; wait 210; netevent ca410w_seed 1; changemap CBTH410; wait 70; changemap MAP01; wait 210; netevent ca410w_resume 1; wait 5; quit',
}
controls = '; '.join(line.strip() for line in (ROOT/'assets/playtest/default_controls.cfg').read_text(encoding='utf-8').splitlines() if line.strip() and not line.lstrip().startswith('//'))
commands['author']=controls+'; wait 1; netevent ca410w_profile; wait 210; netevent ca410w_view 0'
commands['author-smoke']=commands['author']+'; wait 70; netevent ca410w_es; wait 5; quit'
for mode in range(4):
    commands['view'+str(mode)]='wait 1; netevent ca410w_profile; wait 210; netevent ca410w_view 0; wait 70; netevent ca410w_view '+str(mode)+('; ca_journal_page 0; ca_journal_open true' if mode==3 else '')+'; wait 70; screenshot wardrobe-final-view'+str(mode)+'.png; wait 5; quit'
for name,command in commands.items():
    (WORK/('wardrobe-'+name+'.cfg')).write_text(command+'\n',encoding='utf-8')
print('Prepared wardrobe checks with unchanged production mansion geometry.')

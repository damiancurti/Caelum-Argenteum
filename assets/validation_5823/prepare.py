"""Reuse the private mansion hub bridge for constant-climate history checks."""
from pathlib import Path
import runpy
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue410-cooking'
runpy.run_path(str(ROOT/'assets/validation_5822/prepare.py'))
with zipfile.ZipFile(WORK/'bath-checks.pk3') as archive:
    members={name:archive.read(name) for name in archive.namelist()}
members['checks.zs']=(HERE/'checks.zs').read_bytes()
members['MAPINFO']=members['MAPINFO'].replace(b'CA410MBChecks',b'CA502HistoryChecks')
with zipfile.ZipFile(WORK/'history-checks.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,data in sorted(members.items()):
        archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
members['checks.zs']=b'''class CA502HistoryChecks : EventHandler {
Actor Probe;int Passed,Failed;double SavedStamp,SavedAmbient,SavedArea;
override void NetworkProcess(ConsoleEvent e){let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;
u.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
if(e.Name=='ca502h_prepare')Probe=Actor.Spawn('CA502HistoryProp',(496,-896,0),NO_REPLACE);
if(e.Name=='ca502h_seed'){CaelumContaminationStorage.Set(Probe,77);Console.Printf("CA502H PASS original version seeds dirt77");}
if(e.Name=='ca502h_legacy'){
if(Probe!=null && Abs(CaelumContaminationStorage.Value(Probe)-77)<0.000001)Console.Printf("CA502H PASS original package rollback retains actor and dirt");
else Console.Printf("CA502H FAIL original package rollback");}
Console.Printf("CA502H RESULT legacy");}}
class CA502HistoryProp:Actor {Default {Radius8;Height16;+SOLID +NOGRAVITY} States {Spawn:TNT1 A -1;Stop;}}
'''.replace(b'Radius8',b'Radius 8').replace(b'Height16',b'Height 16')
with zipfile.ZipFile(WORK/'history-legacy.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,data in sorted(members.items()):
        archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
commands={
    'core':'wait 210; netevent ca502h_prepare; wait 3; netevent ca502h_core; wait 5; quit',
    'seed':'wait 210; netevent ca502h_prepare; wait 3; netevent ca502h_seed; save history-current23; wait 5; quit',
    'resume':'wait 210; netevent ca502h_resume; wait 5; quit',
    'hub':'wait 210; netevent ca502h_prepare; wait 3; netevent ca502h_seed; changemap CBTH410; wait 210; netevent ca502h_away; changemap MAP01; wait 210; netevent ca502h_resume; wait 5; quit',
    'oldseed':'wait 210; netevent ca502h_prepare; wait 3; netevent ca502h_seed; save history-legacy22; wait 5; quit',
    'legacy':'wait 210; netevent ca502h_legacy; wait 5; quit',
}
for name,command in commands.items():(WORK/('history-'+name+'.cfg')).write_text(command+'\n',encoding='utf-8')
controls='; '.join(line.strip() for line in (ROOT/'assets/playtest/default_controls.cfg').read_text(encoding='utf-8').splitlines() if line.strip() and not line.lstrip().startswith('//'))
manual=commands['hub'].replace('wait 210; netevent ca502h_prepare;','wait 1; netevent ca502h_profile; wait 210; netevent ca502h_manualprepare;').replace('netevent ca502h_seed;','netevent ca502h_seed; netevent ca502h_view;').replace('wait 5; quit','netevent ca502h_view; toggleconsole')
(WORK/'history-author.cfg').write_text(controls+'; '+manual+'\n',encoding='utf-8')
(WORK/'history-author-smoke.cfg').write_text(controls+'; '+manual.replace('netevent ca502h_view; changemap','netevent ca502h_view; wait 5; screenshot history-author-before3.png; changemap').replace('toggleconsole','wait 5; screenshot history-author-final3.png; wait 3; quit')+'\n',encoding='utf-8')
print('Prepared constant-climate exposure probes.')

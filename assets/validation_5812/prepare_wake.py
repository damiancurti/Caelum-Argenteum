"""Build independent exhaustion-wake checks and genuine prior-runtime fixtures."""
from pathlib import Path
import runpy
import zipfile

here=Path(__file__).resolve().parent
out=here.parents[1]/'build/issue502-hygiene'
runpy.run_path(str(here/'prepare_clean.py'))
with zipfile.ZipFile(out/'clean-checks.pk3') as archive:
    original=archive.read('checks.zs').decode('utf-8')
wake=(here/'wake_checks.zs').read_text(encoding='utf-8')
dispatch='''        if(e.Name=='ca502w_core')WakeCore(u);
        else if(e.Name=='ca502w_seed')WakeSeed(u);
        else if(e.Name=='ca502w_load')WakeLoad(u);
        else if(e.Name=='ca502w_liveend')WakeLiveEnd(u);
        else if(e.Name=='ca502w_rev1load'){CleanLoad(u);Check(CaelumCleaningTask.Find(u).Revision==2,"genuine previous-runtime task adopts revision2 without restarting");}
        else if(e.Name=='ca502w_hub')WakeLoad(u,true);
        else if(e.Name=='ca502w_legacyload')WakeLegacyLoad(u);
        else if(e.Name=='ca502w_manual')WakeManual(u);
        else if(e.Name=='ca502w_wake'){WakeNow(u);WakeStatus(u);}
        else if(e.Name=='ca502w_status')WakeStatus(u);
        else if(e.Name=='ca502w_missing'){WakeManual(u);Soap(u,0);WakeNow(u);WakeStatus(u);}
        else if(e.Name=='ca_inventory_boil' '''
legacy=wake[:wake.index('    void WakeNow')]
legacydispatch='''        if(e.Name=='ca502w_legacyseed'){WakeReset(u);Collapse(u);Check(CaelumExhaustion.Locked(u),"prior runtime saves actual exhaustion sleep");}
        else if(e.Name=='ca502w_legacyload'){Check(CaelumExhaustion.Locked(u),"original runtime reopens its exhausted save");Check(!CaelumCleaningTask.Active(u),"original runtime has no post-wake task");}
        else if(e.Name=='ca_inventory_boil' '''
for label,helpers,branches in [('wake-checks',wake,dispatch),('wake-legacy-checks',legacy,legacydispatch)]:
    branches=branches[:branches.rindex("        else if(e.Name=='ca_inventory_boil' ")]+'''        else return false;
        Console.Printf("CA502H RESULT passed=%d failures=%d",Passed,Failed);return true;
    }
'''
    helpers+='\n    bool WakeDispatch(CaelumPlayer u,ConsoleEvent e)\n    {\n'+branches
    source=original.replace('    override void NetworkProcess(ConsoleEvent e)',helpers+'\n    override void NetworkProcess(ConsoleEvent e)',1)
    assert "        if(e.Name=='ca_inventory_boil' " in source
    source=source.replace("        if(e.Name=='ca_inventory_boil' ","        if(WakeDispatch(u,e))return;\n        if(e.Name=='ca_inventory_boil' ",1)
    members={'ZSCRIPT':b'version "4.14.2"\n#include "checks.zs"\n','checks.zs':source.encode(),
        'MAPINFO':b'GameInfo {AddEventHandlers="CA502HChecks"}\n'}
    with zipfile.ZipFile(out/(label+'.pk3'),'w',zipfile.ZIP_STORED) as archive:
        for name,blob in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
scripts={
    'wake-core':'wait 70; netevent ca502w_core; wait 5; quit',
    'wake-live':'wait 70; netevent ca502w_seed; wait 350; netevent ca502w_liveend; wait 5; quit',
    'wake-rev1-load':'wait 1; netevent ca502w_rev1load; wait 5; quit',
    'wake-capture':'wait 70; netevent ca502w_manual; wait 5; screenshot wake-collapse.png; netevent ca502w_wake; wait 2; toggleconsole; wait 10; screenshot wake-start.png; toggleconsole; wait 350; netevent ca502w_liveend; netevent ca502w_status; wait 2; toggleconsole; wait 10; screenshot wake-finished.png; wait 5; quit',
    'wake-save':'wait 70; netevent ca502w_seed; save ca502w-cleaning; wait 5; quit',
    'wake-load':'wait 1; netevent ca502w_load; wait 5; quit',
    'wake-hub':'wait 1; changemap CAH001; wait 70; netevent ca502w_hub; wait 5; quit',
    'wake-legacy-save':'wait 70; netevent ca502w_legacyseed; save ca502w-exhausted; wait 5; quit',
    'wake-legacy-load':'wait 1; netevent ca502w_legacyload; wait 5; quit',
    'wake-manual':'wait 70; netevent ca502w_manual; bind F1 "netevent ca502w_manual"; bind F2 "netevent ca502w_wake; wait 2; toggleconsole"; bind F3 "netevent ca502w_status; wait 2; toggleconsole"; bind F4 "netevent ca502w_missing; wait 2; toggleconsole"; bind F6 toggleconsole',
}
for name,script in scripts.items():(out/(name+'.cfg')).write_text(script+'\n',encoding='utf-8',newline='\n')
print('Prepared deterministic exhaustion-wake fixtures.')

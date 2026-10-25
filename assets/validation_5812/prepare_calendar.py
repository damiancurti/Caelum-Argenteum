"""Build independent calendar-cleanup fixtures without changing accepted packages."""
from pathlib import Path
import runpy, zipfile
here=Path(__file__).resolve().parent
out=here.parents[1]/'build/issue502-hygiene'
runpy.run_path(str(here/'prepare_wake.py'))
with zipfile.ZipFile(out/'wake-checks.pk3') as z: source=z.read('checks.zs').decode('utf-8')
helpers=(here/'calendar_checks.zs').read_text(encoding='utf-8')
dispatch="""    bool CalendarDispatch(CaelumPlayer u,ConsoleEvent e)
    {
        if(e.Name=='ca502c_core')CalendarCore(u);
        else if(e.Name=='ca502c_forecast')CalendarForecast(u);
        else if(e.Name=='ca502c_accelerated')CalendarAccelerated(u);
        else if(e.Name=='ca502c_accelerated_end')CalendarAccelerated(u,true);
        else if(e.Name=='ca502c_edges')CalendarEdges(u);
        else if(e.Name=='ca502c_existingload')CalendarExistingLoad(u);
        else if(e.Name=='ca502c_legacyload')CalendarLegacyLoad(u);
        else if(e.Name=='ca502c_manual')CalendarManual(u);
        else if(e.Name=='ca502c_existing')CalendarManual(u,1);
        else if(e.Name=='ca502c_missing')CalendarManual(u,2);
        else if(e.Name=='ca502c_reading')CalendarManual(u,3);
        else if(e.Name=='ca502c_wake')CalendarWake(u);
        else if(e.Name=='ca502c_cancel'){CaelumTimeSkipState.FinishSkip(u,"CA_SKIP_CANCELLED",true);CalendarStatus(u);}
        else if(e.Name=='ca502c_seed')CalendarSeed(u);
        else if(e.Name=='ca502c_load')CalendarLoad(u);
        else if(e.Name=='ca502c_hub')CalendarLoad(u,true);
        else if(e.Name=='ca502c_liveend')CalendarLiveEnd(u);
        else if(e.Name=='ca502c_status')CalendarStatus(u);
        else return false;
        Console.Printf("CA502H RESULT passed=%d failures=%d",Passed,Failed);return true;
    }
"""
source=source.replace('    override void NetworkProcess(ConsoleEvent e)',helpers+'\n'+dispatch+'\n    override void NetworkProcess(ConsoleEvent e)',1)
source=source.replace('        if(WakeDispatch(u,e))return;','        if(CalendarDispatch(u,e))return;\n        if(WakeDispatch(u,e))return;',1)
members={'ZSCRIPT':b'version "4.14.2"\n#include "checks.zs"\n','checks.zs':source.encode(),'MAPINFO':b'GameInfo {AddEventHandlers="CA502HChecks"}\n'}
with zipfile.ZipFile(out/'calendar-checks.pk3','w',zipfile.ZIP_STORED) as z:
    for name,blob in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
scripts={
'calendar-core':'wait 70; netevent ca502c_core; wait 5; quit',
'calendar-forecast':'wait 70; netevent ca502c_forecast; wait 5; quit',
'calendar-accelerated':'wait 70; netevent ca502c_accelerated; wait 350; netevent ca502c_accelerated_end; wait 5; quit',
'calendar-edges':'wait 70; netevent ca502c_edges; wait 5; quit',
'calendar-existing-save':'wait 70; netevent ca502c_existing; save ca502c-existing; wait 5; quit',
'calendar-existing-load':'wait 1; netevent ca502c_existingload; wait 5; quit',
'calendar-save':'wait 70; netevent ca502c_seed; save ca502c-calendar; wait 5; quit',
'calendar-load':'wait 1; netevent ca502c_load; wait 5; quit',
'calendar-hub':'wait 1; changemap CAH001; wait 70; netevent ca502c_hub; wait 5; quit',
'calendar-live':'wait 70; netevent ca502c_seed; wait 350; netevent ca502c_liveend; wait 5; quit',
'calendar-legacy-save':'wait 70; netevent ca502c_legacyseed; save ca502c-legacy; wait 5; quit',
'calendar-legacy-load':'wait 1; netevent ca502c_legacyload; wait 5; quit',
'calendar-capture':'wait 70; netevent ca502c_manual; wait 2; screenshot calendar-preparing.png; wait 350; netevent ca502c_status; wait 2; screenshot calendar-sleeping.png; netevent ca502c_wake; wait 35; netevent ca502c_status; wait 2; screenshot calendar-resumed.png; wait 5; quit',
'calendar-manual':'wait 70; netevent ca502c_manual; bind F1 "netevent ca502c_manual"; bind F2 "netevent ca502c_status; wait 2; toggleconsole"; bind F3 "netevent ca502c_wake; wait 2; toggleconsole"; bind F4 "netevent ca502c_existing"; bind F5 "netevent ca502c_missing"; bind F6 toggleconsole; bind F7 "netevent ca502c_reading"; bind F8 "netevent ca502c_cancel; wait 2; toggleconsole"',
}
for name,script in scripts.items():(out/(name+'.cfg')).write_text(script+'\n',encoding='utf-8',newline='\n')
# The old addon references only symbols present in the accepted wake runtime.
with zipfile.ZipFile(out/'wake-checks.pk3') as z: legacy=z.read('checks.zs').decode('utf-8')
common=helpers[helpers.index('    CaelumCraftingStation CalendarCraft'):helpers.index('    CaelumRecipeSession CalendarReading')]
old='''    bool CalendarHold;
    override void WorldTick()
    {if(CalendarHold && players[0].mo!=null){let s=CaelumTimeSkipState.Get(CaelumPlayer(players[0].mo));if(s!=null)s.LastPumpTic=level.maptime;}}
    bool CalendarLegacy(CaelumPlayer u,ConsoleEvent e)
    {
        if(e.Name=='ca502c_legacyseed')
        {
            WakeReset(u);CalendarCraft(u);u.CurrentSleep=CaelumTimeSkipRules.SleepAt();
            Check(CaelumTimeSkipState.OpenMenu(u),"legacy calendar opens");let s=CaelumTimeSkipState.Get(u);
            s.UseTaskDefault=false;s.TargetDay=CaelumTimeSkipState.NowDay(u)+1;s.TargetTics=CaelumTimeSkipState.NowTics(u);
            Check(CaelumTimeSkipState.Start(u) && s.Sleeping,"legacy runtime begins automatic sleep without preparation");CalendarHold=true;
        }
        else if(e.Name=='ca502c_existingload')CalendarExistingLoad(u);
        else if(e.Name=='ca502c_legacyload')
        {let s=CaelumTimeSkipState.Get(u);Check(s.Active && s.Sleeping && u.CraftingTaskReservedUnits[0]==17,"original runtime reopens untouched legacy sleeping craft");}
        else return false;
        Console.Printf("CA502H RESULT passed=%d failures=%d",Passed,Failed);return true;
    }
'''
legacy=legacy.replace('    override void NetworkProcess(ConsoleEvent e)',common+old+'\n    override void NetworkProcess(ConsoleEvent e)',1)
legacy=legacy.replace('        if(WakeDispatch(u,e))return;','        if(CalendarLegacy(u,e))return;\n        if(WakeDispatch(u,e))return;',1)
members['checks.zs']=legacy.encode()
with zipfile.ZipFile(out/'calendar-legacy-checks.pk3','w',zipfile.ZIP_STORED) as z:
    for name,blob in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
print('Prepared deterministic calendar-cleanup fixture.')

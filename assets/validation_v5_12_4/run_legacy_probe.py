"""Inspect the additive arena migration on an untouched pre-arena native save."""
from pathlib import Path
import argparse, datetime, hashlib, json, subprocess, sys, time, zipfile
from run_arena_probe import ROOT, ENGINE, IWAD
sys.path.insert(0,str(ROOT))
from migrate_arena_save import migrate

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runtime',type=Path,required=True)
    p.add_argument('--previous',type=Path,required=True)
    p.add_argument('--migrate',action='store_true')
    a=p.parse_args();out=ROOT/'build/issue438'/datetime.datetime.now().strftime('legacy-%Y%m%d-%H%M%S');out.mkdir(parents=True)
    old=zipfile.ZipFile(a.previous/'checks.pk3')
    script='''class CA438Legacy : StaticEventHandler
{
    bool Done;
    override void WorldTick()
    {
        if(Done || level.time<105)return;
        let user=CaelumPlayer(players[0].mo);if(!CaelumWorldClockTicker.Ready(user))return;
        Done=true;
        Console.Printf("CA438 LEGACY arena_handler=%d teamdamage=%g",StaticEventHandler.Find('CaelumArenaEvents')!=null,level.teamdamage);
        Console.Printf("CA438 LEGACY original_record=%d",user.GetPersistentCharacterState(false)!=null);
        let other=CaelumPlayer(players[1].mo);
        if(other.health<=0)CaelumResurrection.Restore(other,other.Pos);
        int before=other.health;other.DamageMobj(user,user,10,'None',DMG_NO_ARMOR,0);
        Console.Printf("CA438 LEGACY friendly_damage=%d",other.health<before);
    }
}'''
    package=out/'checks.pk3'
    with zipfile.ZipFile(package,'w') as z:
        z.writestr('MAPINFO','gameinfo { AddEventHandlers="CA437ClockProbe", "CA438Legacy" }')
        z.writestr('ZSCRIPT','version "4.14.2"\n#include "probe.zs"\n#include "legacy.zs"\n')
        z.writestr('probe.zs',old.read('probe.zs'));z.writestr('legacy.zs',script)
        z.writestr('maps/MAP03.wad',old.read('maps/MAP03.wad'))
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    processes=[]
    try:
        for i in range(2):
            peer=out/f'peer{i}';peer.mkdir()
            saves=list((a.previous/f'peer{i}').glob('*.zds'));assert len(saves)==1
            original=saves[0].read_bytes();data=migrate(original) if a.migrate else original
            assert not a.migrate or migrate(data)==data
            (peer/'recovery.zds').write_bytes(data)
            assert hashlib.sha256(saves[0].read_bytes()).digest()==hashlib.sha256(original).digest()
            (peer/'test.cfg').write_text(f'wait {600+(2-i)*35}; quit\n')
            (peer/'isolated.ini').write_text('[GlobalSettings]\nvid_preferbackend=1\nvid_maxfps=60\nvid_vsync=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\nsnd_mastervolume=0.05\n')
            network=['-host','2','-port','30680','-netmode','0'] if i==0 else ['-join','127.0.0.1:30680','-port','30681']
            cmd=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(a.runtime.resolve()),str(package),'-config',str(peer/'isolated.ini'),'-savedir',str(peer),'-loadgame','recovery.zds','-window','-width','640','-height','480',*network,'+logfile',str(peer/'engine.log'),'+exec',str(peer/'test.cfg')]
            processes.append(subprocess.Popen(cmd,cwd=peer,startupinfo=startup));time.sleep(.3)
        deadline=time.monotonic()+50
        while any(p.poll() is None for p in processes) and time.monotonic()<deadline:time.sleep(.2)
    finally:
        for process in processes:
            if process.poll() is None:process.terminate();process.wait()
    reports=[]
    for i,process in enumerate(processes):
        log=(out/f'peer{i}/engine.log').read_text(errors='replace')
        reports.append({'peer':i,'exit':process.returncode,'observations':[line for line in log.splitlines() if 'CA438 LEGACY' in line], 'errors':[line for line in log.splitlines() if any(t in line for t in ['Execution could not continue','Script error','VM execution aborted'])]})
    passed=all(r['exit']==0 and not r['errors'] and all(s in r['observations'] for s in ['CA438 LEGACY arena_handler=1 teamdamage=1','CA438 LEGACY original_record=1','CA438 LEGACY friendly_damage=1']) for r in reports)
    (out/'results.json').write_text(json.dumps({'issue':438,'previous':str(a.previous),'migration':a.migrate,'passed':passed,'peers':reports},indent=2)+'\n')
    print(str(out));print(json.dumps(reports,indent=2))
    if not passed:raise SystemExit(1)

if __name__=='__main__':main()

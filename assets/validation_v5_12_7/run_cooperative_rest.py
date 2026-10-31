"""Run consent and rest through real native events and actor ticks, never direct Pump calls."""
from pathlib import Path
from types import SimpleNamespace
import argparse,datetime,json,zipfile
import run_author_suite as suite


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ('engine','runtime','anchor'):parser.add_argument('--'+name,type=Path,required=True)
    parser.add_argument('--diagnose',action='store_true')
    args=parser.parse_args()
    for name in ('engine','runtime','anchor'):setattr(args,name,getattr(args,name).resolve(strict=True))
    original=suite.fixture
    def fixture(output,anchor,scene,diagnose=False):
        original(output,anchor,scene)
        with zipfile.ZipFile(output) as z:members={n:z.read(n) for n in z.namelist()}
        members['ZSCRIPT']+=b'\n#include "rest_probe.zs"\n'
        members['MAPINFO']+=b'\ngameinfo { AddEventHandlers="CA435RestProbe" }\n'
        members['rest_probe.zs']=Path(__file__).with_name('cooperative_rest_probe.zs').read_bytes()
        if args.diagnose:
            source=(suite.ROOT/'src/caelum/world/CaelumRest.zs').read_text(encoding='utf-8')
            marker='if (user.health < rest.LastHealth) reason = "CA_REST_DAMAGE";'
            source=source.replace(marker,'''if(reason=="CA_REST_TIME_CHANGED")
                Console.Printf("CA435REST CLOCK slot=%d now=%d last=%d tic=%d pumping=%d serial=%d",
                    user.PlayerNumber(),clock.DayTics,rest.LastClockDayTics,level.time,
                    CaelumTimeAdvanceState.Get(user)!=null && CaelumTimeAdvanceState.Get(user).Pumping,
                    CaelumTimeAdvanceState.StepSerial(user));
            '''+marker)
            members['caelum/world/CaelumRest.zs']=source.encode()
            source=(suite.ROOT/'src/caelum/world/CaelumCooperativeTime.zs').read_text(encoding='utf-8')
            source=source.replace('int slot=vote.Slot(user);if(slot<0)return;', '''int slot=vote.Slot(user);if(slot<0)return;
            if(level.time<222)Console.Printf("CA435REST STEP slot=%d tic=%d predicting=%d seen=%d seentic=%d",slot,level.time,int((user.player.cheats&CF_PREDICTING)!=0),vote.Seen,vote.SeenTic);''')
            source=source.replace('clock.AdvanceOnMap(level.MapName);', '''if(level.time<222 && step<3)for(int debug=0;debug<2;debug++)
                Console.Printf("CA435REST PUMP slot=%d tic=%d step=%d now=%d last=%d predict=%d",debug,level.time,step,CaelumWorldClock.Get(Members[debug]).DayTics,CaelumRestState.Get(Members[debug]).LastClockDayTics,int((Members[debug].player.cheats&CF_PREDICTING)!=0));
            clock.AdvanceOnMap(level.MapName);''')
            members['caelum/world/CaelumCooperativeTime.zs']=source.encode()
        with zipfile.ZipFile(output,'w') as z:
            for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
    suite.fixture=fixture
    home=suite.ROOT/'build/issue435'/datetime.datetime.now().strftime('cooperative-rest-%Y%m%d-%H%M%S-%f');home.mkdir()
    result=suite.launch(SimpleNamespace(**vars(args),smoke=True,diagnose_ui=False),home,1)
    logs=list(home.glob('scene*/bundle/peer*/engine.log'))
    if not logs:logs=list(home.glob('scene*/**/engine.log'))
    checks=[[l for l in p.read_text(errors='replace').splitlines() if l.startswith('CA435REST ')] for p in logs]
    result['rest_checks']=checks
    result['passed']=result['passed'] and len(checks)==2 and all(any(' RESULT ' in l for l in lines) and not any(' FAIL ' in l for l in lines) for lines in checks)
    (home/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(directory=str(home),passed=result['passed'],checks=checks),indent=2))
    raise SystemExit(not result['passed'])


if __name__=='__main__':main()

"""Sequential matched runs; no engine overlap or package building during timing."""
from pathlib import Path
import argparse
import subprocess
import sys
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('group',choices=['views','components','repeat','siege','skip','encounter','doors','render','references','pitch','portals','geometry','geometry2'])
    args=parser.parse_args();plans=[]
    if args.group in ('geometry','geometry2'):
        overlay='collinear-diagnostic-v2.pk3' if args.group=='geometry2' else 'collinear-diagnostic.pk3'
        for pitch in (0,75,75,0):
            plans.append(('base',['--pitch',str(pitch),'--addon','build/issue318-audit-02/'+overlay,'--postwait','210','--fixture',str(ROOT/'build/issue318-audit-02/observer-v4.pk3')]))
        if args.group=='geometry2':
            for pitch in (0,75):
                plans.append(('base',['--pitch',str(pitch),'--addon','build/issue318-audit-02/'+overlay,'--addon2','build/issue318-audit-02/no-doors.pk3','--postwait','210','--fixture',str(ROOT/'build/issue318-audit-02/observer-v4.pk3')]))
    elif args.group=='portals':
        for pitch in (0,75):
            plans.append(('base',['--pitch',str(pitch),'--commands','gl_portals false','--postwait','210','--fixture',str(ROOT/'build/issue318-audit-02/observer-v4.pk3')]))
    elif args.group=='pitch':
        for pitch in (45,47,47,45):
            plans.append(('base',['--pitch',str(pitch),'--postwait','210','--fixture',str(ROOT/'build/issue318-audit-02/observer-v4.pk3')]))
    elif args.group=='references':
        for mapname in ('MAP01','MAP02'):
            for pitch in (0,75,75,0):
                plans.append(('base',['--map',mapname,'--site','-1','--pitch',str(pitch),'--postwait','210','--fixture',str(ROOT/'build/issue318-audit-02/observer-v4.pk3')]))
            plans.append(('profile',['--map',mapname,'--site','-1','--fixture',str(ROOT/'build/issue318-audit-02/observer-v4.pk3')]))
    elif args.group=='render':
        for pitch in (0,75):
            for addon in (False,True):
                extra=['--pitch',str(pitch),'--commands','stat rendertimes; stat renderstats','--postwait','210']
                if addon:extra+=['--addon','build/issue318-audit-02/no-doors.pk3']
                plans.append(('base',extra))
        for pitch in (0,75):
            plans.append(('base',['--pitch',str(pitch),'--freeze','--postwait','210']))
        for extra in (['--width','640','--height','360'],['--commands','gl_lights false; r_dynlights false; r_actorspriteshadow 0'],['--commands','r_drawplayersprites false'],['--user-config']):
            plans.append(('base',['--pitch','75']+extra))
        for site in (0,2):
            for pitch in (0,75):plans.append(('base',['--site',str(site),'--pitch',str(pitch)]))
    elif args.group=='doors':
        for pitch in (0,75):
            for removed in (False,True,True,False):
                extra=['--pitch',str(pitch)]
                if removed:extra+=['--addon','build/issue318-audit-02/no-doors.pk3']
                plans.append(('base',extra))
    elif args.group=='views':
        for site in (0,1,2):
            for pitch in (0,75,75,0):
                plans.append(('base',['--site',str(site),'--pitch',str(pitch)]))
        for pitch in (0,75):
            plans.append(('base',['--site','1','--pitch',str(pitch),'--freeze']))
        plans.append(('base',['--site','1','--width','640','--height','360']))
        plans.append(('base',['--site','1','--user-config']))
    elif args.group=='components':
        for variant in ('profile','base','blockers-off','base','blockers-stationary','npc-tick-off','thermal-off','stats-off','carbine-off','contacts-off','population-off','pressure-off','hints-off','hud-off','base'):
            plans.append((variant,[]))
    elif args.group=='repeat':
        for variant in ('base','blockers-stationary','blockers-stationary','base','thermal-off','thermal-off','npc-tick-off','blockers-off','pressure-off'):
            plans.append((variant,[]))
    elif args.group=='encounter':
        for variant in ('base','breath-off','profile-deep'):
            plans.append((variant,['--phase','1','--site','4','--warmup','70','--window','35','--timeout','300']))
        plans.append(('base',['--phase','2','--site','4','--window','700','--timeout','240']))
        for variant in ('profile','base','breath-off'):
            plans.append((variant,['--phase','3','--warmup','70','--window','35','--timeout','300']))
    elif args.group=='siege':
        plans=[('profile',['--phase','1','--site','4','--window','175','--timeout','300']),
               ('base',['--phase','1','--site','4','--window','350','--timeout','300']),
               ('base',['--phase','2','--site','4','--window','700','--timeout','240'])]
    elif args.group=='skip':
        plans=[('profile',['--phase','3','--window','140','--timeout','300']),('base',['--phase','3','--window','140','--timeout','300'])]
    failed=[]
    for i,(variant,extra) in enumerate(plans,1):
        stop=ROOT/'build/issue318-audit-02/stop-after-current.signal'
        if stop.exists() and stop.read_text().strip()=='stop':
            print('Stopped between runs; current evidence retained',flush=True);break
        label=f'{args.group}-{i:02d}-{variant}'
        record=ROOT/'build/issue318-audit-02'/variant/(label+'-run.json')
        if record.exists():
            import json
            prior=json.loads(record.read_text())
            prior_log=record.with_name(label+'.txt').read_text(encoding='utf-8',errors='replace')
            if prior.get('exit_code')==0 and 'CA318 DONE' in prior and not prior.get('engine_error') and not prior.get('watchdog_timeout') and 'CA318 FAIL' not in prior_log and 'CA318 DONE failures=0' in prior_log:
                print('REUSE completed',label,flush=True);continue
        command=[sys.executable,str(HERE/'run.py'),'--label',label,'--variant',variant,'--global-presentmon']+extra
        if args.group in ('siege','skip','encounter','render'):
            command+=['--fixture',str(ROOT/'build/issue318-audit-02/observer-v3.pk3')]
        print('PLAN',label,flush=True)
        result=subprocess.run(command,cwd=ROOT)
        if result.returncode:
            failed.append(label)
            if args.group!='encounter':raise SystemExit(result.returncode)
    if failed:
        print('Incomplete runs retained:',', '.join(failed),flush=True)
        raise SystemExit(1)

if __name__=='__main__':main()

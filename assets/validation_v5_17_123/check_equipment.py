"""Exercise final terminal controls, matching reload and native hub return."""
from pathlib import Path
import argparse,json,re
from author_terminal import catalog
from sessions import ROOT,load_config,prepare,reload_session,run,write_json,sha

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--config',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();config=load_config(a.config);out=a.output.resolve();out.relative_to(ROOT/'build/author-889')
    out.mkdir(parents=True,exist_ok=False)
    action=dict(next(r for r in catalog()['actions'] if r['id']=='equipment'))
    # Existing catalogue counts: head5, body11, hands4, feet5. Each extra step
    # visits native unequip and returns to the original first owned garment.
    commands=''
    for region,count in [(0,5),(1,11),(2,4),(3,5)]:
        commands+=''.join(f'netevent ca889_region {region}; wait 5; ' for _ in range(count+1))
    commands+='netevent ca889_view; wait 5; netevent ca889_view; wait 5; netevent ca889_view; wait 5; netevent ca889_view; wait 5; '
    commands+='netevent ca889_weapon; wait 70; +reload; wait 3; -reload; wait 350; '
    commands+='netevent ca889_weapon; wait 70; +reload; wait 3; -reload; wait 350; '
    commands+='netevent ca889_weapon; wait 70; '
    commands+='netevent ca889_sex; wait 20; netevent ca889_sex; wait 20; '
    commands+='netevent ca889_moon; wait 20; netevent ca889_state; screenshot equipment-controls.png; '
    action['smoke_commands']=commands
    fresh=prepare(action,config,out/'fresh',smoke=True);rows=[run(fresh,hidden=True)]
    assert rows[-1]['passed'],rows[-1]
    log=(out/'fresh/engine.log').read_text(encoding='utf-8',errors='replace')
    assert log.count('CA889 EQUIPMENT CYCLE region=')==33
    assert 'CA889 DIAGNOSTIC MOON started=1' in log and 'attributes100=1' in log
    assert 'CA889 EQUIPMENT VISUAL weapon=0 shield=1 body=CaelumWardrobePilotBody' in log
    original_ids=re.findall(r'^CA889 OWNED .+$',log,re.M);assert len(original_ids)==4
    reload=reload_session(out/'fresh',out/'fresh/terminal-smoke.zds',out/'reload',smoke=True)
    cfg=Path(reload['command'][reload['command'].index('+exec')+1])
    s=cfg.read_text();s=s.replace('event ca889_ready;', 'event ca889_ready; netevent ca889_state; wait 5;',1)
    cfg.write_text(s,encoding='utf-8',newline='\n')
    rows.append(run(reload,hidden=True));assert rows[-1]['passed'],rows[-1]
    log=(out/'reload/engine.log').read_text(encoding='utf-8',errors='replace')
    assert re.findall(r'^CA889 OWNED .+$',log,re.M)==original_ids
    assert 'CA889 EQUIPMENT VISUAL weapon=0 shield=1 body=CaelumWardrobePilotBody' in log
    travel=reload_session(out/'fresh',out/'fresh/terminal-smoke.zds',out/'travel',smoke=True)
    cfg=Path(travel['command'][travel['command'].index('+exec')+1])
    s=cfg.read_text();s=s.replace('event ca889_ready;','event ca889_ready; changemap CA889B; wait 70; event ca889_ready; changemap CA836A; wait 70; event ca889_ready; netevent ca889_state; netevent ca889_view; wait 5;',1)
    cfg.write_text(s,encoding='utf-8',newline='\n')
    rows.append(run(travel,hidden=True));assert rows[-1]['passed'],rows[-1]
    log=(out/'travel/engine.log').read_text(encoding='utf-8',errors='replace')
    assert 'CA889 READY map=CA889B' in log and re.findall(r'^CA889 OWNED .+$',log,re.M)==original_ids
    assert 'CA889 EQUIPMENT VISUAL weapon=0 shield=1 body=CaelumWardrobePilotBody' in log
    result=dict(issue=889,passed=True,rows=rows,cycle_calls=33,all_catalogue_regions=True,
                native_weapon_inputs=['carbine reload','staff charge'],moon_started=True,attributes100=True,
                owned_ids_identical_after_reload_and_return=True,save_sha256=sha(out/'fresh/terminal-smoke.zds'),
                wardrobe_body_restored=True,buckler_restored=True,
                qualification='Fixture setup grants canonical owned objects and diagnostic Moon initialization. Native controls, save and return are exercised; this is not campaign eligibility or author acceptance.')
    write_json(out/'RESULTS.json',result);print(json.dumps(result))

if __name__=='__main__':
    main()

"""Check the equipment room's native death menu and corpse checkpoint."""
from pathlib import Path
import argparse,json,re
from sessions import ROOT,reload_session,run,write_json

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--previous',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();previous=a.previous.resolve(strict=True)
    out=a.output.resolve();out.relative_to(ROOT/'build/author-889')
    record=reload_session(previous,previous/'terminal-smoke.zds',out,smoke=True)
    cfg=Path(record['command'][record['command'].index('+exec')+1])
    text=cfg.read_text(encoding='utf-8').replace('event ca889_ready;',
        'event ca889_ready; netevent ca889_view; wait 5; netevent ca889_death; wait 70; netevent ca889_state; wait 5;',1)
    cfg.write_text(text,encoding='utf-8',newline='\n')
    result=run(record,hidden=True)
    assert result['passed'],result
    log=(out/'engine.log').read_text(encoding='utf-8',errors='replace')
    state=re.findall(r'^CA889 SNAPSHOT frozen=1 .+$',log,re.M);assert len(state)==1
    assert re.search(r'CA889 EQUIPMENT STATE .*health=-\d+',log)
    recovered=reload_session(out,out/'terminal-smoke.zds',out/'dead-reload',smoke=True)
    cfg=Path(recovered['command'][recovered['command'].index('+exec')+1])
    text=cfg.read_text(encoding='utf-8').replace('event ca889_ready;',
        'event ca889_ready; netevent ca889_state; wait 5;',1)
    cfg.write_text(text,encoding='utf-8',newline='\n')
    loaded=run(recovered,hidden=True);assert loaded['passed'],loaded
    log=(out/'dead-reload/engine.log').read_text(encoding='utf-8',errors='replace')
    assert re.findall(r'^CA889 SNAPSHOT frozen=1 .+$',log,re.M)==state
    assert re.search(r'CA889 EQUIPMENT STATE .*health=-\d+',log)
    report=dict(issue=889,passed=True,rows=[result,loaded],frozen_snapshot_identical=True,
        host_players=1,qualification='One-player cooperative diagnostic room permits native dead-player saves. No campaign death rule is changed.',author_acceptance=False)
    write_json(out/'DEATH-RESULTS.json',report);print(json.dumps(report))

if __name__=='__main__':
    main()

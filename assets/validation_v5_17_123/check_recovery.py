"""Verify exact-option environment reload and reject a changed package binding."""
from pathlib import Path
import argparse,json
from sessions import ROOT,reload_session,run,sha,write_json

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--previous',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();previous=a.previous.resolve(strict=True)
    out=a.output.resolve();out.relative_to(ROOT/'build/author-889')
    out.mkdir(parents=True,exist_ok=False)
    save=previous/'terminal-smoke.zds'
    record=reload_session(previous,save,out/'reload',smoke=True)
    assert record['command'][record['command'].index('-loadgame')+1]=='restore.zds'
    assert sha(save)==sha(out/'reload/restore.zds')
    cfg=Path(record['command'][record['command'].index('+exec')+1])
    text=cfg.read_text(encoding='utf-8').replace('event ca889_ready;',
        'event ca889_ready; netevent ca866_next; wait 10;',1)
    cfg.write_text(text,encoding='utf-8',newline='\n')
    result=run(record,hidden=True);assert result['passed'],result
    log=(out/'reload/engine.log').read_text(encoding='utf-8',errors='replace')
    assert 'CA887 SURFACE PASS candidate=1' in log
    # A metadata-only negative fixture never changes a real package or save.
    invalid=out/'changed-binding';invalid.mkdir()
    data=json.loads((previous/'session.json').read_text(encoding='utf-8'))
    first=next(iter(data['packages']));data['packages'][first]='0'*64
    write_json(invalid/'session.json',data)
    rejected=None
    try:reload_session(invalid,save,out/'must-not-be-created',smoke=True)
    except AssertionError as error:rejected=str(error)
    assert rejected and 'El paquete' in rejected
    assert not (out/'must-not-be-created').exists()
    report=dict(issue=889,passed=True,native=result,basename_load=True,
        source_save_sha256=sha(save),copied_save_sha256=sha(out/'reload/restore.zds'),
        source_preserved=True,changed_binding_rejected=rejected,
        rejected_before_new_output=True,author_acceptance=False)
    write_json(out/'RESULTS.json',report);print(json.dumps(report))

if __name__=='__main__':
    main()

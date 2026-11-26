"""Exercise the text menu without opening a native scene or recording a verdict."""
from pathlib import Path
import argparse,json,subprocess,sys
from sessions import ROOT,HERE,write_json

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--config',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();out=a.output.resolve();out.relative_to(ROOT/'build')
    out.mkdir(parents=True,exist_ok=False)
    result=subprocess.run([sys.executable,'-X','utf8',str(HERE/'author_terminal.py'),
        '--config',str(a.config.resolve())],cwd=ROOT,input='8\n9\n2\n\n3\n\n4\n887\n\n0\n',
        text=True,encoding='utf-8',capture_output=True,timeout=30)
    (out/'stdout.txt').write_text(result.stdout,encoding='utf-8',newline='\n')
    (out/'stderr.txt').write_text(result.stderr,encoding='utf-8',newline='\n')
    assert result.returncode==0 and not result.stderr,result.stderr
    for phrase in ['108 comprobaciones pendientes.','Idioma: EN.','Comparaciones de mapas',
                   'Equipo y cuerpo','CA887-WATERLINE-01','Estado y decisiones pendientes']:
        assert phrase in result.stdout,phrase
    state=json.loads((ROOT/'build/author-889/terminal-state.json').read_text(encoding='utf-8'))
    assert state['wake_request_succeeded'] and not state['active'] and not state['system_required']
    write_json(out/'RESULTS.json',dict(issue=889,passed=True,menu_navigation=True,
        language_selection=True,search=True,wake_requested_and_released=True,
        scenes_opened=0,author_acceptance=False,state=state))
    print('Terminal menu, language, search and temporary wake lease passed.')

if __name__=='__main__':
    main()

"""Reuse the native peer/save harness; keep #448 fixtures and results separate."""
from pathlib import Path
import sys

if __name__=='__main__':
    source=(Path(__file__).resolve().parents[1]/'validation_v5_15_0/run_native.py').read_text(encoding='utf-8')
    source=source.replace('issue447','issue448').replace('CA447','CA448').replace('ca447','ca448')
    source=source.replace('issue=447','issue=448')
    if '--spanish' in sys.argv:
        sys.argv.remove('--spanish');source=source.replace('language=en','language=es')
    source=source.replace('T447','T448').replace('levelnum=448','levelnum=449').replace('levelnum=447','levelnum=448')
    source=source.replace('cluster=447','cluster=448').replace('cluster 447','cluster 448')
    source=source.replace('Port.Defenders[0]==First && Port.Defenders[1]==Second','Port.Defenders[1]==First && Port.Defenders[2]==Second')
    source=source.replace('save checkpoint; ','save checkpoint; wait 5; screenshot military-menu.png; ')
    source=source.replace("duration=(500 if args.suite=='travel' else 210)","duration=(500 if args.suite=='travel' or args.load_directory else 210)")
    namespace=dict(__file__=__file__,__name__='ca448_shared_runner')
    exec(compile(source,__file__,'exec'),namespace)
    namespace['main']()

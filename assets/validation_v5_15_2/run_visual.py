"""Capture native barricade geometry and the unpaused ES/EN machine panel."""
from pathlib import Path
import sys

if __name__=='__main__':
    previous=Path(__file__).resolve().parents[1]/'validation_v5_15_0/run_native.py'
    source=previous.read_text(encoding='utf-8')
    source=source.replace('issue447','issue449').replace('CA447','CA449').replace('ca447','ca449').replace('issue=447','issue=449')
    source=source.replace('wait 5; save checkpoint; ',
        'wait 5; netevent ca449_visual; wait 12; screenshot barricade.png; netevent ca449_panel; wait 12; screenshot machine-panel.png; save checkpoint; ')
    source=source.replace('language=en','language=es' if 'spanish' in sys.argv[1] else 'language=en')
    exec(compile(source,str(previous),'exec'),dict(__file__=__file__,__name__='__main__'))

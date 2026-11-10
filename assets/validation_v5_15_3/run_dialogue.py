"""Inspect real guard dialogue and invoke its actual native inventory action."""
from pathlib import Path
import sys

if __name__=='__main__':
    previous=Path(__file__).resolve().parents[1]/'validation_v5_15_0/run_native.py'
    source=previous.read_text(encoding='utf-8')
    source=source.replace('issue447','issue450').replace('CA447','CA450').replace('ca447','ca450').replace('issue=447','issue=450')
    source=source.replace('wait 5; save checkpoint; ',
        'wait 5; netevent ca450_dialogue; wait 12; screenshot guard-dialogue.png; netevent ca450_reportaction; wait 12; screenshot report.png; save checkpoint; ')
    source=source.replace('language=en','language=es' if 'spanish' in sys.argv[1] else 'language=en')
    source=source.replace("else 'CA450 CHECKPOINT READY failures=0'","else 'CA450 DIALOGUE PASS'")
    exec(compile(source,str(previous),'exec'),dict(__file__=__file__,__name__='__main__'))

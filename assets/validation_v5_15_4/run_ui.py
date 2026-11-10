"""Capture the actual transport and Journal views in each supported language."""
from pathlib import Path
import sys

if __name__=='__main__':
    previous=Path(__file__).resolve().parents[1]/'validation_v5_15_0/run_native.py'
    source=previous.read_text(encoding='utf-8')
    source=source.replace('issue447','issue451').replace('CA447','CA451').replace('ca447','ca451').replace('issue=447','issue=451')
    source=source.replace('wait 5; save checkpoint; ',
        'wait 5; netevent ca451_transportui; wait 15; screenshot transport.png; netevent ca451_journalui; ca_journal_open true; ca_journal_page 4; ca_journal_quest_selected 11; ca_journal_quest_detail true; ca_journal_quest_scroll 999; wait 15; screenshot occupied-journal.png; save checkpoint; ')
    source=source.replace('language=en','language=es' if 'spanish' in sys.argv[1] else 'language=en')
    source=source.replace("else 'CA451 CHECKPOINT READY failures=0'","else 'CA451 UI PASS'")
    source=source.replace("duration=(500 if args.suite=='travel' else 210)","duration=(500 if args.suite=='travel' else 500)")
    exec(compile(source,str(previous),'exec'),dict(__file__=__file__,__name__='__main__'))

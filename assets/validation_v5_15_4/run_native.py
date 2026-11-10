"""Keep #451 native outcome/save/hub evidence separate from its prerequisites."""
from pathlib import Path

if __name__=='__main__':
    previous=Path(__file__).resolve().parents[1]/'validation_v5_15_0/run_native.py'
    source=previous.read_text(encoding='utf-8')
    source=source.replace('issue447','issue451').replace('CA447','CA451').replace('ca447','ca451').replace('issue=447','issue=451')
    source=source.replace('T447','T451').replace('levelnum=448','levelnum=452').replace('levelnum=447','levelnum=451')
    source=source.replace('cluster=447','cluster=451').replace('cluster 447','cluster 451')
    source=source.replace('wait 5; save checkpoint;', 'wait 5; +forward; wait 70; -forward; netevent ca451_walk; wait 5; save checkpoint;')
    source=source.replace("duration=(500 if args.suite=='travel' else 210)","duration=(800 if args.suite=='travel' else 500)")
    source=source.replace("choices=('standard','legacy','catchup','travel')","choices=('standard','legacy','catchup','travel','victory','away')")
    source=source.replace("args.suite=='travel')","args.suite in ('travel','away'))")
    source=source.replace("            duration=", "            if args.suite=='victory':host='wait 90; netevent ca451_seed; wait 15; netevent ca451_victory; '\n            if args.suite=='away':host=host.replace('save checkpoint;','netevent ca451_prepareaway; netevent ca451_travel; wait 70; netevent ca451_advanceaway; wait 5; netevent ca451_return; wait 70; netevent ca451_verifyaway;')\n            duration=")
    source=source.replace("        okay=", "        if args.suite=='victory':marker='CA451 VICTORY PASS'\n        if args.suite=='away':marker='CA451 AWAY PASS'\n        okay=")
    exec(compile(source,str(previous),'exec'),dict(__file__=__file__,__name__='__main__'))

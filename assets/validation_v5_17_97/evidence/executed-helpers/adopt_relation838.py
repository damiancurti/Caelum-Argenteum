"""Adopt the verified read-only relationship ordering and current release markers."""
from pathlib import Path
import hashlib,re,subprocess
root=Path(__file__).resolve().parents[2]/'build/v517/work-713'
assert subprocess.check_output(['git','branch','--show-current'],cwd=root,text=True).strip()=='issue838-siege-bursts'
path='caelum/actors/CaelumVisualPerception.zs'
assert hashlib.sha256((root/'src'/path).read_bytes()).hexdigest()=='0325c735f34c281fe1e57fe8b9525cbfb4c550822871b7193503d1ff8f4d5401'
(root/'src'/path).write_bytes((root/'build/issue838-relation01/source'/path).read_bytes())
versioned=[root/'AGENTS.md']+[p for p in (root/'docs').iterdir() if p.suffix in ('.md','.txt') and 'Documentation version:' in p.read_text(encoding='utf-8')[:1000]]
assert len(versioned)==9
for p in versioned:
    s=p.read_text(encoding='utf-8');s,n=re.subn(r'(?m)^(Documentation version: \*\*)5\.17\.96(\*\* - 2026-11-19\.)$',r'\g<1>5.17.97\2',s,count=1)
    assert n==1,p;p.write_text(s,encoding='utf-8',newline='\n')
p=root/'README.md';s=p.read_text(encoding='utf-8');assert s.count('**Current release: 5.17.96.**')==1
s=s.replace('**Current release: 5.17.96.**','**Current release: 5.17.97.**',1)
anchor='#836 reduces repeated high-density perception work'
assert s.count(anchor)==1
s=s.replace(anchor,'#838 avoids relationship queries for unreachable shared candidates only when\nthe relationship path has no state updates. Resident and delegated paths retain\ntheir original order. Native equivalence passed; final package/save and\npresentation checks are in progress. Siege stalls remain unresolved.\n\n'+anchor,1)
p.write_text(s,encoding='utf-8',newline='\n')
for name in ('CaelumPhysicalHazards.zs','CaelumSewerMaze.zs'):
    p=root/'src/caelum/world'/name;s=p.read_bytes();assert s.count(b'[Caelum 5.17.96]')==1
    p.write_bytes(s.replace(b'[Caelum 5.17.96]',b'[Caelum 5.17.97]'))
title='## 5.17.97 - Skip unreachable read-only relationship queries (#838, #454)\n\n'
for name in ('PROJECT.md','TASKS.md','HISTORY.md','ASSETS.md'):
    p=root/'docs'/name;s=p.read_text(encoding='utf-8');at=s.index('\n## ')
    s=s[:at]+'\n'+title+'The existing shared-candidate reach rejection now precedes relationship\nqueries only for ordinary observers whose relationship path reads state.\nResidents, summoned bodies, automatons and clones retain the previous ordering.\nThe sampled native oracle matches 2,066 queries; prototype edge checks pass.\nFinal package checks are in progress. No author acceptance or batch completion.\n'+s[at:]
    p.write_text(s,encoding='utf-8',newline='\n')
p=root/'docs/SYSTEMS.md';s=p.read_text(encoding='utf-8');anchor='A previously unknown body requires two active seconds of continuous visual'
assert s.count(anchor)==1
s=s.replace(anchor,'''#838 / 5.17.97 moves that bound before the relationship query only for observers
outside the anchored-resident, summoned-Zupay, tarot-automaton and tarot-clone
class families. Their ordinary relationship path reads state; skipped candidates
already fail the unchanged reach bound. Null entries are discarded safely.
Excluded families keep relationship-before-bound ordering: resident reputation
can maintain player material schemas, including through delegated target checks.
All retained candidates still pass the original relationship and visibility
functions in the same list order. Portal fallback, allies, private evidence,
cache priority, clocks, whole-map census and saved fields remain unchanged.

'''+anchor,1);p.write_text(s,encoding='utf-8',newline='\n')
p=root/'docs/CONTEXT.md';s=p.read_text(encoding='utf-8')
old='#836:shared-query filter;256save/edge checks;zero sampled mismatches;siege~1.78presents/s.'
assert s.count(old)==1
s=s.replace(old,'#838:early relation filter;2,066queries matched;prototype p95=47.48ms;final checks pending.').replace('siege stalls (#836).','siege stalls (#838).',1)
p.write_text(s,encoding='utf-8',newline='\n')
out=root/'assets/validation_v5_17_97';out.mkdir(exist_ok=False)
for before,after in [('run_relation_edges838.py','run_relation_edges.py'),('relation_edges838.zs','relation_edges838.zs'),('prepare_relation838.py','prepare_relation.py'),('prepare_relation_oracle838.py','prepare_relation_oracle.py')]:
    s=Path(__file__).with_name(before).read_text(encoding='utf-8')
    s=s.replace("root=helper.parents[1]/'build/v517/work-713'","root=Path(__file__).resolve().parents[2]")
    s=s.replace("root=Path(__file__).resolve().parents[2]/'build/v517/work-713'","root=Path(__file__).resolve().parents[2]")
    (out/after).write_text(s,encoding='utf-8',newline='\n')
print('Adopted #838; current version 5.17.97; historical headings retained; context words='+str(len((root/'docs/CONTEXT.md').read_text(encoding='utf-8').split())))

"""Adopt the measured query reduction; retain historical labels and saves."""
from pathlib import Path
import json,re,shutil
R=Path(__file__).resolve().parents[2]/'build/v517/work-713'
path='caelum/actors/CaelumVisualPerception.zs'
source=(R/'build/issue836-reach02/source'/path).read_text(encoding='utf-8')
assert source.count('+0.01')==2
source=source.replace('+0.01','+CaelumPerceptionData.CONTACT_MARGIN')
(R/'src'/path).write_text(source,encoding='utf-8',newline='\n')
p=R/'src/caelum/data/CaelumPerceptionData.zs';s=p.read_text(encoding='utf-8')
anchor='    const NATIVE_FULL_LIGHT = 255.0;'
assert s.count(anchor)==1 and 'CONTACT_MARGIN' not in s
s=s.replace(anchor,anchor+'\n    // #836: margen de contacto preexistente, compartido con la cota exterior.\n    const CONTACT_MARGIN = 0.01;')
p.write_text(s,encoding='utf-8',newline='\n')
versioned=[R/'AGENTS.md']+[p for p in (R/'docs').iterdir() if p.suffix in ('.md','.txt') and 'Documentation version:' in p.read_text(encoding='utf-8')[:1000]]
assert len(versioned)==9
for p in versioned:
    s=p.read_text(encoding='utf-8');s,n=re.subn(r'(?m)^(Documentation version: \*\*)5\.17\.95(\*\* - 2026-11-19\.)$',r'\g<1>5.17.96\2',s,count=1)
    assert n==1,p;p.write_text(s,encoding='utf-8',newline='\n')
p=R/'README.md';s=p.read_text(encoding='utf-8');assert s.count('**Current release: 5.17.95.**')==1
s=s.replace('**Current release: 5.17.95.**','**Current release: 5.17.96.**',1)
anchor='#834 completes an isolated IQM format assessment.'
s=s.replace(anchor,'#836 reduces repeated high-density perception work with a conservative spatial\nfilter. Native equivalence and portal checks pass; final package/save and\npresentation measurements are in progress. Siege fluency remains unresolved.\n\n'+anchor,1);p.write_text(s,encoding='utf-8',newline='\n')
for name in ('CaelumPhysicalHazards.zs','CaelumSewerMaze.zs'):
    p=R/'src/caelum/world'/name;s=p.read_text(encoding='utf-8');assert s.count('[Caelum 5.17.95]')==1
    p.write_text(s.replace('[Caelum 5.17.95]','[Caelum 5.17.96]'),encoding='utf-8',newline='\n')
title='## 5.17.96 - Conservative shared-candidate reach rejection (#836, #454)\n\n'
for name in ('PROJECT.md','TASKS.md','HISTORY.md','ASSETS.md'):
    p=R/'docs'/name;s=p.read_text(encoding='utf-8');at=s.index('\n## ')
    s=s[:at]+'\n'+title+'The production high-density candidate loop rejects only bodies beyond a\nconservative horizontal reach bound. Original selection predicates and order\nremain for every retained candidate; linked-portal maps use the original path.\nNative prototype equivalence and portal checks passed. Final package tests and\nmeasurements are in progress; no author acceptance or full-batch completion.\n'+s[at:]
    p.write_text(s,encoding='utf-8',newline='\n')
p=R/'docs/SYSTEMS.md';s=p.read_text(encoding='utf-8');anchor='A previously unknown body requires two active seconds of continuous visual'
paragraph='''#836 / 5.17.96 adds a conservative broadphase only within the existing shared
high-density group query. Once per query, it derives maximum sight from the
observer's current Insight. Each candidate's current height gives the full-light,
zero-stealth upper reach; nonnegative physical radii and the existing 0.01-MU
contact margin enlarge that bound. A body farther away on either horizontal
axis cannot satisfy sight or contact. All retained bodies keep their original
relationship, native distance, contact, field, light, stealth and sight checks,
ordered nearest selection and private recognition. The bound is recomputed from
current data, not a saved cache or another actor scan. GZDoom portal-group count
must be exactly one; linked-portal maps retain native portal-aware queries.
The shared CONTACT_MARGIN constant relocates the existing value without changing
it. No gameplay value, cadence, saved field or revision changes.

'''
assert s.count(anchor)==1;s=s.replace(anchor,paragraph+anchor,1);p.write_text(s,encoding='utf-8',newline='\n')
p=R/'docs/CONTEXT.md';s=p.read_text(encoding='utf-8');s=s.replace('**V5.16:** #452/453 approved;', '#836:conservative shared-query filter;equivalence/portal checks pass;final tests pending.\n**V5.16:** #452/453 approved;',1);p.write_text(s,encoding='utf-8',newline='\n')
out=R/'assets/validation_v5_17_96';out.mkdir(exist_ok=False)
runner=Path(__file__).with_name('run_reach_edges836.py').read_text(encoding='utf-8')
runner=runner.replace("ROOT=Path(__file__).resolve().parents[2]/'build/v517/work-713'","ROOT=Path(__file__).resolve().parents[2]")
(out/'run_reach_edges.py').write_text(runner,encoding='utf-8',newline='\n')
print('Adopted #836 production filter, preserved existing contact value, advanced current headers only to 5.17.96.')

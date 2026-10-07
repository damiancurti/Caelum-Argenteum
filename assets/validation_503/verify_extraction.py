"""Check retained schemas, all extracted statements, adapters and remaining code."""
from pathlib import Path
import hashlib, json, re, subprocess, sys, zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
BASE='135ae0f91de84a7d4f4b3c0f803da254aeacd0ad'
sys.path.insert(0,str(ROOT/'assets/validation_500'))
from audit_sources import declarations

def old(path):return subprocess.check_output(['git','show',f'{BASE}:{path}'],cwd=ROOT).decode()
def tokens(s):
    s=re.sub(r'("(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\')|//[^\n]*|/\*[\s\S]*?\*/',lambda m:m.group(1) or '',s)
    return re.findall(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|\w+|[^\s]',s)
def method(s,cls,name):return next(m for c in declarations(s) if c['name']==cls for m in c['methods'] if m['name']==name)
def body(s,m):return s[m['body_start']:m['body_end']+1]
manifest=json.loads((HERE/'extraction_manifest.json').read_text())
service=(ROOT/'src/caelum/core/CaelumTarotService.zs').read_text(encoding='utf-8')
assert not declarations(service)[0]['fields']
record_methods=['HasTarotCard','CountTarotCards','GetTarotAttributeBonusPercent','GetTarotMinorBaseBonus','CanCaptureMainM00Fool','RecordMainM00FoolCapture']
for entry in manifest:
    s=old(entry['path']);m=method(s,entry['cls'],entry['name'])
    moved=body(service,method(service,'CaelumTarotService',entry['target']))
    if entry['target']=='Advance':
        assert moved.count('RestoreNativeEffect(user);')==1
        moved=moved.replace('RestoreNativeEffect(user);','')
    for name in record_methods:
        for record in ['record','persistentState']:
            moved=moved.replace(name+'('+record+', ',record+'.'+name+'(').replace(name+'('+record+')',record+'.'+name+'()')
    for name in ['IsAvailable','IsRevealedFor','RecordCapture']:
        moved=moved.replace(name+'(essence, ','essence.'+name+'(')
    moved=moved.replace('CanCaptureArcana(','CaelumArcanaProgress.CanCapture(')
    for a,b in reversed(entry['replacements']):
        if a=='CaelumTrucazoRules.' and b=='':
            moved=re.sub(r'\b(Minor|Suit|Rank)\(',r'CaelumTrucazoRules.\1(',moved)
        else:moved=moved.replace(b,a)
    if entry['receiver']:moved=re.sub(r'\b'+entry['receiver']+r'\.', '',moved)
    assert tokens(moved)==tokens(body(s,m)),entry['name']

paths={entry['path'] for entry in manifest}|{
    'src/caelum/player/CaelumPlayerPresentation.zs','src/caelum/player/CaelumPlayer.zs',
    'src/caelum/hud/CaelumJournalOverlay.zs','src/caelum/hud/CaelumHUDOverlay.zs',
    'src/caelum/world/CaelumJourneyPlan.zs','src/caelum/trucazo/CaelumTrucazoMatch.zs','src/caelum/trucazo/CaelumTrucoMatch.zs'}
schemas={}
for path in sorted(paths):
    before=old(path);after=(ROOT/path).read_text(encoding='utf-8')
    bdecl=declarations(before);adecl=declarations(after)
    assert len(bdecl)==len(adecl)
    for b,a in zip(bdecl,adecl):
        assert b['fields']==a['fields'] or [f['declaration'] for f in b['fields']]==[f['declaration'] for f in a['fields']],path
        assert [m['signature'] for m in b['methods']]==[m['signature'] for m in a['methods']],path
        schemas[b['name']]=dict(fields=len(b['fields']),methods=len(b['methods']))
    replacements=[]
    for e in [e for e in manifest if e['path']==path]:
        m=method(before,e['cls'],e['name']);n=method(after,e['cls'],e['name'])
        params=m['signature'].split('(',1)[1].rsplit(')',1)[0]
        args=[p.split('=')[0].split()[-1] for p in params.split(',') if p.strip()]
        call='CaelumTarotService.'+e['target']+'('+', '.join((['self'] if e['receiver'] else [])+args)+');'
        if 'void ' not in m['signature'].split('(')[0]:call='return '+call
        assert tokens(body(after,n))==tokens('{'+call+'}'),e
        replacements.append((m['body_start'],m['body_end']+1,'{'+call+'}'))
    for a,b,v in sorted(replacements,reverse=True):before=before[:a]+v+before[b:]
    if path.endswith('CaelumPlayerPresentation.zs'):
        a=before.index('        CaelumTarotPowers.EnsureRevision(persistentState);');b=before.index('        user.JournalPalomoPlacement',a)
        before=before[:a]+'        CaelumTarotService.RefreshJournalSnapshot(user, persistentState);\n'+before[b:]
    if path.endswith('CaelumMainM00FoolCapture.zs'):
        before=before.replace('if (CardId() == CaelumConstants.TAROT_THE_FOOL) record.MainM00FoolRevealed = true;\n            else record.ArcanaRevealed[CardId()] = true;','CaelumTarotService.Reveal(record, CardId());')
    if path.endswith('CaelumTarotPowers.zs'):
        before=before.replace('record == null || record.TarotEffectTics <= 0\n            || !record.TarotActive[CaelumConstants.TAROT_THE_FOOL]','!CaelumTarotService.IsActive(record, CaelumConstants.TAROT_THE_FOOL)').replace('EffectTics = record.TarotEffectTics + 1;','EffectTics = CaelumTarotService.EffectTics(record) + 1;')
    if not any(e['path']==path for e in manifest) and not path.endswith('CaelumPlayerPresentation.zs'):
        before=before.replace('CaelumTarotPowers.','CaelumTarotService.').replace('CaelumTarotDeckRules.Owned(','CaelumTarotService.HasPhysicalDeck(')
        before=before.replace('record.TarotEffectTics','CaelumTarotService.EffectTics(record)').replace('record.TarotCooldownTics','CaelumTarotService.CooldownTics(record)').replace('record.TarotSelected[card]','CaelumTarotService.IsSelected(record, card)').replace('record.TarotActive[selected]','CaelumTarotService.IsActive(record, selected)').replace('record.HasTarotCard(card)','CaelumTarotService.HasTarotCard(record, card)')
        if path.endswith('CaelumPlayer.zs'):before=before.replace('Super.Travelled();\n        RestorePersistentCharacterState();','Super.Travelled();\n        RestorePersistentCharacterState();\n        CaelumTarotService.RestoreNativeEffect(self);')
    assert tokens(before)==tokens(after),path
with zipfile.ZipFile(ROOT/'build/issue119/baseline.pk3') as b,zipfile.ZipFile(ROOT/'build/issue119/current.pk3') as c:
    added=sorted(set(c.namelist())-set(b.namelist()));removed=sorted(set(b.namelist())-set(c.namelist()))
    changed=sorted(n for n in b.namelist() if n in c.namelist() and b.read(n).replace(b'\r\n',b'\n')!=c.read(n).replace(b'\r\n',b'\n'))
    assert not removed and added==['caelum/core/CaelumTarotService.zs']
    assert set(changed)=={p[4:] for p in paths}|{'ZSCRIPT','caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs'}
report=dict(result='PASS',baseline=BASE,stateless=True,moved_methods=len(manifest),retained_schemas=schemas,
    complete_remaining_code_checked=True,explicit_behavior_fix='RestoreNativeEffect: idempotent recovery of missing native flight from the already-paid saved active set; no schema, payment or timer change.',
    package_added=added,package_removed=removed,package_changed=changed,
    package_sha256=hashlib.sha256((ROOT/'build/issue119/current.pk3').read_bytes()).hexdigest())
(HERE/'EXTRACTION.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print('PASS: 24 moved implementations; schemas, adapters, remaining bodies and package boundary verified')

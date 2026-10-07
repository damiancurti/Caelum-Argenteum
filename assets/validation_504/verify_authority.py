"""Verify guards, retained bodies/schemas, event routes and package boundaries."""
from pathlib import Path
import hashlib,json,re,subprocess,sys,zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
BASE='c4b717c7e8ab49e0cbe1a6f67e7f15f18c850b52'
sys.path.insert(0,str(ROOT/'assets/validation_500'))
from audit_sources import declarations
def old(path):return subprocess.check_output(['git','show',f'{BASE}:{path}'],cwd=ROOT).decode('utf-8')
def tokens(s):
    s=re.sub(r'("(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\')|//[^\n]*|/\*[\s\S]*?\*/',lambda m:m.group(1) or '',s)
    return re.findall(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|\w+|[^\s]',s)
def method(s,cls,name):return next(m for c in declarations(s) if c['name']==cls for m in c['methods'] if m['name']==name)
manifest=json.loads((HERE/'authority_manifest.json').read_text())
paths={e['path'] for e in manifest}|{'src/caelum/player/CaelumPlayer.zs','src/caelum/hud/CaelumJournalOverlay.zs','src/caelum/trucazo/CaelumTrucazoMenu.zs','src/caelum/trucazo/CaelumTrucoMenu.zs','src/caelum/core/CaelumTarotPowers.zs'}
schemas={}
for path in sorted(paths):
    before=old(path);after=(ROOT/path).read_text(encoding='utf-8');normalized=after
    bdecl=declarations(before);adecl=declarations(after)
    assert len(bdecl)==len(adecl),path
    for b,a in zip(bdecl,adecl):
        assert [f['declaration'] for f in b['fields']]==[f['declaration'] for f in a['fields']],path
        assert [m['signature'] for m in b['methods']]==[m['signature'] for m in a['methods']],path
        schemas[b['name']]=dict(fields=len(b['fields']),methods=len(b['methods']))
    removals=[]
    for e in [e for e in manifest if e['path']==path]:
        m=method(after,e['cls'],e['name']);start=m['body_start']+1
        guard='\n        '+e['guard']
        assert after[start:start+len(guard)]==guard,e
        removals.append((start,start+len(guard)))
    for a,b in sorted(removals,reverse=True):normalized=normalized[:a]+normalized[b:]
    if path.endswith('CaelumPlayer.zs'):
        normalized=normalized.replace('\n        if (!CaelumPlayerAuthority.CanRead(self)) return null;','',1)
        normalized=normalized.replace('if (persistentState != null && persistentState.Owner != self) return null;\n        if (persistentState == null && createState && CaelumPlayerAuthority.CanMutate(self))','if (persistentState == null && createState)')
    if path.endswith('CaelumJournalOverlay.zs'):
        normalized=normalized.replace('CaelumPlayerAuthority.FromNetworkPlayer(e.Player)','CaelumPlayer(players[e.Player].mo)')
    for game in ['Trucazo','Truco']:
        if path.endswith(f'Caelum{game}Menu.zs'):
            normalized=normalized.replace(f'if(e.Name!="ca_{game.lower()}")return;\n        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);\n        if(user==null)return;\n        let match=Caelum{game}Match.Get(user);',f'if(e.Name!="ca_{game.lower()}" || e.Player<0 || e.Player>=MAXPLAYERS || !playeringame[e.Player])return;\n        let match=Caelum{game}Match.Get(CaelumPlayer(players[e.Player].mo));')
    if path.endswith('CaelumTarotPowers.zs'):normalized=normalized.replace('const REVISION = CaelumTarotService.REVISION;','const REVISION = 1;')
    assert tokens(before)==tokens(normalized),path
authority=(ROOT/'src/caelum/player/CaelumPlayerAuthority.zs').read_text(encoding='utf-8')
assert not declarations(authority)[0]['fields']
assert 'consoleplayer' not in authority and 'players[0]' not in authority
assert 'record.Owner == user' in authority and 'CF_PREDICTING' in authority
assert 'user.FindInventory("CaelumPersistentCharacterState") == record' in authority
assert authority.index('number < 0')<authority.index('players[number].mo')
with zipfile.ZipFile(ROOT/'build/issue120/baseline.pk3') as b,zipfile.ZipFile(ROOT/'build/issue120/current.pk3') as c:
    added=sorted(set(c.namelist())-set(b.namelist()));removed=sorted(set(b.namelist())-set(c.namelist()))
    changed=sorted(n for n in b.namelist() if n in c.namelist() and b.read(n).replace(b'\r\n',b'\n')!=c.read(n).replace(b'\r\n',b'\n'))
    assert not removed and added==['caelum/player/CaelumPlayerAuthority.zs']
    assert set(changed)=={p[4:] for p in paths}|{'ZSCRIPT','caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs'},changed
    for n in changed+added:
        assert c.read(n).replace(b'\r\n',b'\n')==(ROOT/'src'/n).read_bytes().replace(b'\r\n',b'\n'),n
report=dict(result='PASS',baseline=BASE,guarded_operations=len(manifest),stateless_authority=True,retained_schemas=schemas,complete_remaining_bodies_checked=True,package_added=added,package_removed=removed,package_changed=changed,package_sha256=hashlib.sha256((ROOT/'build/issue120/current.pk3').read_bytes()).hexdigest())
(HERE/'AUTHORITY.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(f'PASS: {len(manifest)} exact guards; schemas, retained bodies, routes and final package verified')

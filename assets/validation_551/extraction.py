"""Reproduce or verify the bounded #310 combat dispatch extraction."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import subprocess
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE.parent/'validation_500'))
from audit_sources import declarations, mask

BASE = 'ca8206bc98b2713c7ec5159df63c07a5276501ff'
PLAYER = 'src/caelum/player/CaelumPlayer.zs'
SERVICE = 'CaelumCombatDispatch'
DEST = f'src/caelum/player/{SERVICE}.zs'
METHODS = ('PerformEquippedWeaponPrimaryAttack', 'PerformLargeWeaponSweep',
           'PerformEquippedWeaponSecondaryAttack')
GUARD = 'if (!CaelumPlayerAuthority.CanMutate(user)) return;'


def tokens(text):
    return re.findall(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|\w+|[^\s]',
        re.sub(r'("(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\')|//[^\n]*|/\*[\s\S]*?\*/',
               lambda m: m.group(1) or '', text))


def expected():
    original = subprocess.check_output(['git','show',f'{BASE}:{PLAYER}'],cwd=ROOT).decode('utf-8')
    pawn = next(c for c in declarations(original) if c['name']=='CaelumPlayer')
    names = {m['name'] for m in pawn['methods']}
    for field in pawn['fields']:
        for part in field['declaration'].split(','):
            names.add(re.sub(r'\[.*','',part.split()[-1]))
    edits=[]
    output=['// #310: coordina solicitudes sobre el receptor explícito, sin estado propio.\n'
            '// El jugador conserva temporizadores, commits y datos serializados.\n'
            f'class {SERVICE} : Object play\n{{\n']
    for name in METHODS:
        method=next(m for m in pawn['methods'] if m['name']==name)
        signature=method['signature']
        params=signature[signature.index('(')+1:signature.rindex(')')]
        args=[p.split()[-1] for p in params.split(',') if p.strip()]
        body=original[method['body_start']:method['body_end']+1]
        clean=mask(body); replacements=[]
        for token in re.finditer(r'\b\w+\b',clean):
            word=token.group()
            if word=='self': replacement='user'
            elif word in names and word not in args and not clean[:token.start()].rstrip().endswith('.'):
                replacement='user.'+word
            else: continue
            replacements.append((token.start(),token.end(),replacement))
        for start,end,replacement in reversed(replacements): body=body[:start]+replacement+body[end:]
        body=body.replace('{','{\n        '+GUARD,1)
        sig=signature[:signature.index('(')+1]+'CaelumPlayer user'+(', '+params.strip() if params.strip() else '')+')'
        output.append('    static '+sig+'\n    '+body+'\n\n')
        call=f'{SERVICE}.{name}(self'+(', '+', '.join(args) if args else '')+');'
        edits.append((method['body_start'],method['body_end']+1,'{\n        '+call+'\n    }'))
    output.append('}\n')
    changed=original
    for start,end,replacement in sorted(edits,reverse=True): changed=changed[:start]+replacement+changed[end:]
    return original, changed, ''.join(output)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply',action='store_true')
    args=parser.parse_args()
    original, expected_player, expected_service=expected()
    if args.apply:
        (ROOT/PLAYER).write_text(expected_player,encoding='utf-8',newline='\n')
        (ROOT/DEST).write_text(expected_service,encoding='utf-8',newline='\n')
    player=(ROOT/PLAYER).read_text(encoding='utf-8')
    service=(ROOT/DEST).read_text(encoding='utf-8')
    assert player==expected_player, 'Unexpected pawn changes outside the exact extraction'
    assert service==expected_service, 'Unexpected service change/order'
    before=next(c for c in declarations(original) if c['name']=='CaelumPlayer')
    after=next(c for c in declarations(player) if c['name']=='CaelumPlayer')
    helper=declarations(service)[0]
    assert not helper['fields']
    assert [f['declaration'] for f in before['fields']]==[f['declaration'] for f in after['fields']]
    assert [m['signature'] for m in before['methods']]==[m['signature'] for m in after['methods']]
    for name in METHODS:
        old=next(m for m in before['methods'] if m['name']==name)
        new=next(m for m in helper['methods'] if m['name']==name)
        body=service[new['body_start']:new['body_end']+1]
        assert body.count(GUARD)==1
        restored=re.sub(r'\buser\.', '', body.replace(GUARD,''))
        restored=re.sub(r'\buser\b','self',restored)
        assert tokens(original[old['body_start']:old['body_end']+1])==tokens(restored),name
    report=dict(baseline=BASE,result='PASS',moved=list(METHODS),
                unchanged_fields=len(before['fields']),unchanged_signatures=len(before['methods']),
                unchanged_other_bodies=len(before['methods'])-len(METHODS),
                sole_added_guard=GUARD,stateless_service=True)
    package=ROOT/'build/caelum_argenteum_dev.pk3'
    old_package=ROOT/'build/issue309-persist04/production.pk3'
    with zipfile.ZipFile(old_package) as old, zipfile.ZipFile(package) as new:
        added=sorted(set(new.namelist())-set(old.namelist()))
        removed=sorted(set(old.namelist())-set(new.namelist()))
        changed=sorted(n for n in old.namelist() if n in new.namelist() and old.read(n)!=new.read(n))
        assert added==[DEST[4:]] and not removed
        expected_changes=['ZSCRIPT',PLAYER[4:],'caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs']
        assert changed==expected_changes
        for n in expected_changes[2:]:
            assert old.read(n).replace(b'5.5.0',b'5.5.1').replace(b'\r\n',b'\n')==new.read(n).replace(b'\r\n',b'\n')
        report.update(package_added=added,package_changed=changed,package_removed=removed,
            normal_package_sha256=hashlib.sha256(package.read_bytes()).hexdigest())
    (HERE/'extraction.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(report))


if __name__=='__main__': main()

"""Check every pawn declaration/body and the complete runtime package boundary."""
import hashlib
import json
import re
import zipfile
from extract_domains import ROOT, BASE, PLAYER, DOMAINS, baseline, arguments, declarations

HERE = __import__('pathlib').Path(__file__).resolve().parent


def tokens(text):
    # Preserve quoted literals while removing comments and insignificant whitespace.
    return re.findall(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|\w+|[^\s]',
        re.sub(r'("(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\')|//[^\n]*|/\*[\s\S]*?\*/',
               lambda m: m.group(1) or '', text))


old, new = baseline(), (ROOT / PLAYER).read_text(encoding='utf-8')
before, after = (next(c for c in declarations(s) if c['name'] == 'CaelumPlayer') for s in (old, new))
assert [f['declaration'] for f in before['fields']] == [f['declaration'] for f in after['fields']]
assert [m['signature'] for m in before['methods']] == [m['signature'] for m in after['methods']]
moved = {name: service for service, names in DOMAINS.items() for name in names}
helpers = {}
for service in DOMAINS:
    source = (ROOT / f'src/caelum/player/{service}.zs').read_text(encoding='utf-8')
    decl = declarations(source)[0]
    assert not decl['fields']
    helpers[service] = source, {m['name']: m for m in decl['methods']}
for prior, current in zip(before['methods'], after['methods']):
    left, right = (s[m['body_start']:m['body_end'] + 1] for s, m in ((old, prior), (new, current)))
    name = prior['name']
    if name not in moved:
        assert left == right, name
        continue
    params, args = arguments(prior['signature'])
    call = moved[name] + '.' + name + '(self' + (', ' + ', '.join(args) if args else '') + ');'
    if not prior['signature'].startswith('void '): call = 'return ' + call
    assert tokens(right) == tokens('{' + call + '}'), name
    source, methods = helpers[moved[name]]
    method = methods[name]
    body = source[method['body_start']:method['body_end'] + 1]
    restored = re.sub(r'\buser\.', '', body)
    restored = re.sub(r'\buser\b', 'self', restored)
    assert tokens(left) == tokens(restored), name
with zipfile.ZipFile(ROOT/'build/issue117/baseline.pk3') as base, zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as final:
    added = sorted(set(final.namelist()) - set(base.namelist()))
    removed = sorted(set(base.namelist()) - set(final.namelist()))
    changed = sorted(n for n in base.namelist() if n in final.namelist() and base.read(n) != final.read(n))
    newline_only = [n for n in changed if base.read(n).replace(b'\r\n',b'\n') == final.read(n).replace(b'\r\n',b'\n')]
    semantic_changes = [n for n in changed if n not in newline_only]
    assert not removed
    assert added == [f'caelum/player/{n}.zs' for n in sorted(DOMAINS)]
    assert set(newline_only) <= {'caelum/player/CaelumPlayerPresentation.zs'}
    assert semantic_changes == ['ZSCRIPT', PLAYER[4:], 'caelum/world/CaelumPhysicalHazards.zs', 'caelum/world/CaelumSewerMaze.zs']
    for name in semantic_changes[2:]:
        assert base.read(name).decode().replace('5.0.0', '5.0.1').replace('\r\n','\n') == final.read(name).decode().replace('\r\n','\n')
report = dict(baseline=BASE, result='PASS', unchanged_field_declarations=len(before['fields']),
    unchanged_signatures=len(before['methods']), moved_methods=DOMAINS, stateless_services=True,
    unchanged_other_method_bodies=len(before['methods'])-len(moved),
    player_lines_removed=len(old.splitlines())-len(new.splitlines()),
    package_members_added=added, package_members_changed=changed, package_members_removed=removed,
    checkout_newline_only_members=newline_only,
    package_sha256=hashlib.sha256((ROOT/'build/caelum_argenteum_dev.pk3').read_bytes()).hexdigest())
(HERE/'EXTRACTION.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
print('PASS: 39 equivalent method moves; all fields, signatures and other method bodies retained')

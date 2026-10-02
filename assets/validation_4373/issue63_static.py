"""Check the issue-63 dialogue graph, localization and packaged sources."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import zipfile

def blocks(text, kind):
    result = []
    for match in re.finditer(r'\b' + kind + r'\s*\{', text):
        depth = 1; i = match.end(); quoted = False
        while depth:
            char = text[i]
            if char == '"' and text[i-1] != '\\': quoted = not quoted
            if not quoted:
                if char == '{': depth += 1
                elif char == '}': depth -= 1
            i += 1
        result.append(text[match.start():i])
    return result

def pages(text):
    result = []
    for c in blocks(text, 'conversation'):
        cid = int(re.search(r'\bid\s*=\s*(\d+)', c)[1])
        for index, p in enumerate(blocks(c, 'page')):
            name = re.search(r'\bpagename\s*=\s*"([^"]+)"', p)
            result.append((cid, name[1] if name else f'@{index}'))
    return result

base = subprocess.check_output(['git','show','40c06804:src/CAPALOMO']).decode('utf-8')
current = Path('src/CAPALOMO').read_text(encoding='utf-8')
old_pages = pages(base); new_pages = pages(current)
assert new_pages[:len(old_pages)] == old_pages, 'Saved native page order changed'
for c in blocks(current, 'conversation'):
    names = [name for _, name in pages(c)]
    assert len(names) == len(set(names)), 'Duplicate page within a conversation'
    for target in re.findall(r'\b(?:nextpage|link)\s*=\s*"([^"]+)"', c):
        assert target in names, target
loadout = next(c for c in blocks(current, 'conversation') if re.search(r'\bid\s*=\s*43630;',c))
assert len(re.findall(r'giveitem\s*=\s*"CaelumM00Choose', loadout)) == 49
language = Path('src/LANGUAGE').read_text(encoding='utf-8')
keys = set(re.findall(r'\$(CA_[A-Z0-9_]+)', loadout))
keys.update(re.findall(r'^(CA_LOADOUT_\w+)\s*=', language, re.M))
localized = {'default': set(), 'es': set()}; languages = []
for line in language.splitlines():
    match = re.match(r'\s*\[([^]]+)\]', line)
    if match: languages = match[1].split()
    match = re.match(r'\s*(CA_\w+)\s*=', line)
    if match:
        for lang in languages:
            if lang in localized: localized[lang].add(match[1])
for lang in localized:
    assert not keys - localized[lang], (lang, sorted(keys - localized[lang]))
source = {p.relative_to('src').as_posix():p.read_bytes() for p in Path('src').rglob('*') if p.is_file()}
with zipfile.ZipFile('build/caelum_argenteum_dev.pk3') as z:
    assert set(z.namelist()) == set(source)
    assert all(z.read(name) == data for name, data in source.items()), 'PK3 is stale'
hashes = {name:hashlib.sha256(data).hexdigest() for name,data in sorted(source.items())}
result = {'status':'PASS','old_page_indices_preserved':len(old_pages),
          'total_pages':len(new_pages),'choices':49,'localized_keys':len(keys),
          'languages':list(localized),'source_entries_match_pk3':len(source),
          'pk3_sha256':hashlib.sha256(Path('build/caelum_argenteum_dev.pk3').read_bytes()).hexdigest(),
          'source_tree_sha256':hashlib.sha256(json.dumps(hashes,sort_keys=True).encode()).hexdigest()}
Path('build/issue63_static.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps(result,indent=2))

#!/usr/bin/env python3
"""Build/check ordered dialogue sources and bounded localization navigation."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import sys

ROOT = Path(__file__).resolve().parent
TOKEN = re.compile(r'//[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*"|[A-Za-z_]\w*|-?\d+(?:\.\d+)?|[^\s]', re.S)


def tokens(text):
    return [m for m in TOKEN.finditer(text) if not m[0].startswith(('//', '/*'))]


def value(token):
    return json.loads(token) if token.startswith('"') else token


def blocks(text, kind='conversation'):
    """Read balanced USDF blocks without interpreting strings as syntax."""
    items = tokens(text)
    result = []
    i = 0
    while i < len(items):
        if items[i][0].lower() != kind or i + 1 >= len(items) or items[i+1][0] != '{':
            i += 1
            continue
        start = i
        i += 2
        depth = 1
        while i < len(items) and depth:
            depth += (items[i][0] == '{') - (items[i][0] == '}')
            i += 1
        if depth:
            raise ValueError(f'Unclosed {kind} block at line {text.count(chr(10), 0, items[start].start())+1}')
        first, last = items[start].start(), items[i-1].end()
        body = text[first:last]
        result.append(dict(text=body, start=first, end=last,
                           line=text.count('\n', 0, first)+1,
                           end_line=text.count('\n', 0, last)+1,
                           tokens=[m[0] for m in items[start:i]]))
    return result


def field(block, name):
    ts = block['tokens']
    for i in range(len(ts)-2):
        if ts[i].lower() == name and ts[i+1] == '=':
            return value(ts[i+2])
    return None


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def safe_source(source, relative):
    path = (source / relative).resolve()
    if not path.is_relative_to(source.resolve()) or not path.is_file():
        raise ValueError(f'Missing or out-of-source path: {relative}')
    return path


def load_catalogue(source):
    manifest = json.loads((source / 'dialogues/index.json').read_text(encoding='utf-8'))
    if manifest.get('schema') != 1:
        raise ValueError('Unsupported dialogue index schema')
    conversations = {}
    names = set()
    source_paths = [owner['path'] for owner in manifest['sources']]
    discovered = {p.relative_to(source).as_posix() for folder in ('npc', 'shared')
                  for p in (source / 'dialogues' / folder).glob('*.usdf')}
    if set(source_paths) != discovered or len(source_paths) != len(set(source_paths)):
        raise ValueError('Manifest must include each NPC/shared USDF source exactly once')
    for owner in manifest['sources']:
        if owner['name'] in names:
            raise ValueError(f'Duplicate source name: {owner["name"]}')
        names.add(owner['name'])
        path = safe_source(source, owner['path'])
        text = path.read_text(encoding='utf-8')
        lexed = tokens(text)
        ts = [m[0] for m in lexed]
        if ts[:4] != ['namespace', '=', '"GZDoom"', ';']:
            raise ValueError(f'{owner["path"]}: expected GZDoom namespace')
        parsed = blocks(text)
        consumed = 4 + sum(len(b['tokens']) for b in parsed)
        if consumed != len(ts):
            raise ValueError(f'{owner["path"]}: unsupported top-level content')
        previous = lexed[3].end()
        for block in parsed:
            ident = int(field(block, 'id'))
            if ident in conversations:
                raise ValueError(f'Duplicate conversation ID: {ident}')
            block.update(id=ident, owner=owner, decorated=text[previous:block['end']].strip())
            previous = block['end']
            pages = blocks(block['text'], 'page')
            page_names = [field(page, 'pagename') for page in pages if field(page, 'pagename')]
            if len(page_names) != len(set(n.lower() for n in page_names)):
                raise ValueError(f'{ident}: duplicate page name')
            bt = block['tokens']
            targets = [value(bt[i+2]) for i in range(len(bt)-2)
                       if bt[i].lower() in ('nextpage','link') and bt[i+1] == '=' and bt[i+2].startswith('"')]
            missing = set(n.lower() for n in targets) - set(n.lower() for n in page_names)
            if missing:
                raise ValueError(f'{ident}: unresolved pages: {sorted(missing)}')
            block['pages'] = pages
            conversations[ident] = block
        if text[previous:].strip():
            # Preserve trailing comments as part of the final conversation.
            if not parsed or tokens(text[previous:]):
                raise ValueError(f'{owner["path"]}: unexpected trailing content')
            conversations[ident]['decorated'] += text[previous:].rstrip()
    order = manifest['order']
    if len(order) != len(set(order)) or set(order) != set(conversations):
        raise ValueError('Dialogue order must list every conversation exactly once')
    return manifest, [conversations[ident] for ident in order]


def language_index(path):
    """Index complete quoted LANGUAGE assignments, including repeated sections."""
    text = path.read_text(encoding='utf-8-sig')
    ts = tokens(text)
    languages = []
    entries = {}
    i = 0
    while i < len(ts):
        token = ts[i][0]
        if token == '[':
            i += 1
            languages = []
            while i < len(ts) and ts[i][0] != ']':
                languages.append(ts[i][0])
                i += 1
            if not languages or i == len(ts):
                raise ValueError('Malformed LANGUAGE section')
            i += 1
            continue
        if not languages or i+1 >= len(ts) or ts[i+1][0] != '=':
            raise ValueError(f'Unsupported LANGUAGE token: {token}')
        key = token
        first = ts[i].start()
        i += 2
        values = []
        while i < len(ts) and ts[i][0] != ';':
            if not ts[i][0].startswith('"'):
                raise ValueError(f'{key}: unsupported LANGUAGE value')
            values.append(ts[i][0])
            i += 1
        if not values or i == len(ts):
            raise ValueError(f'{key}: incomplete LANGUAGE assignment')
        location = [text.count('\n', 0, first)+1, text.count('\n', 0, ts[i].end())+1]
        for lang in languages:
            entries.setdefault(key, {}).setdefault(lang, []).append(location)
        i += 1
    return dict(schema=1, source='LANGUAGE', sha256=digest(path), entries=dict(sorted(entries.items())))


def localized_keys(block):
    return sorted({value(t)[1:] for t in block['tokens'] if t.startswith('"$')})


def bilingual(entry):
    return 'es' in entry and ('enu' in entry or 'default' in entry)


def validate_history(root, conversations, localization):
    data = json.loads((root / 'assets/dialogue_history.json').read_text(encoding='utf-8'))
    for row in data['entries']:
        required = {row[k].lstrip('$') for k in ('source', 'reply', 'answer')}
        if not any(required <= set(localized_keys(block)) and
                   any(field(page, 'pagename') == row['page'] for page in block['pages'])
                   for block in conversations):
            raise ValueError(f'Dialogue history entry no longer resolves: {row["reply"]}')
        for key in required:
            if not bilingual(localization['entries'].get(key, {})):
                raise ValueError(f'Dialogue history localization missing: {key}')


def outputs(root, source):
    manifest, conversations = load_catalogue(source)
    localization = language_index(source / 'LANGUAGE')
    for block in conversations:
        for key in localized_keys(block):
            if not bilingual(localization['entries'].get(key, {})):
                raise ValueError(f'{block["id"]}: missing English/Spanish localization: {key}')
    validate_history(root, conversations, localization)
    runtime = 'namespace = "GZDoom";\n\n// Generado por build_dialogue_index.py; editar las fuentes del index.json.\n\n'
    runtime += '\n\n'.join(b['decorated'] for b in conversations) + '\n'
    result = {source / 'dialogues/runtime.usdf': runtime}
    index = ['# Dialogue source index', '',
             'Generated by `python build_dialogue_index.py build`; check freshness before using line ranges.',
             'Authoritative load manifest: [index.json](index.json). Each NPC owns one source file.',
             'The generated runtime preserves the complete original conversation/page order.',
             'Localization: [LANGUAGE index](../localization/INDEX.md).', '',
             'Commands from the repository root:', '',
             '```powershell', 'python build_dialogue_index.py check',
             'python build_dialogue_index.py npc palomo',
             'python build_dialogue_index.py read CA_LOADOUT_INTRO', '```', '',
             '`npc NAME` prints conversation/page ranges and localization keys; add `--conversation ID`',
             'to select one tree or `--page NAME` to select one page. Read only the needed source range.',
             'Runtime-generated text keys are also discoverable with `find TERM` in the complete LANGUAGE index.', '',
             '| NPC / system | Authoritative source | Conversation IDs |', '| --- | --- | --- |']
    for owner in manifest['sources']:
        owned = [b for b in conversations if b['owner']['name'] == owner['name']]
        index.append(f'| {owner["name"]} | [{owner["path"].split("/")[-1]}]({owner["path"].removeprefix("dialogues/")}) | '+', '.join(str(b['id']) for b in owned)+' |')
    index += ['', 'Source SHA-256 fingerprints:', '']
    for owner in manifest['sources']:
        index.append(f'- `{owner["path"]}`: `{digest(source / owner["path"])}`')
    index.append(f'- `dialogues/index.json`: `{digest(source / "dialogues/index.json")}`')
    result[source / 'dialogues/INDEX.md'] = '\n'.join(index) + '\n'
    # Keep one key per line so a targeted text search remains readable.
    packed = ['{', '  "schema": 1,', '  "source": "LANGUAGE",',
              f'  "sha256": "{localization["sha256"]}",', '  "entries": {']
    entries = list(localization['entries'].items())
    for i, (key, locations) in enumerate(entries):
        packed.append('    '+json.dumps(key)+': '+json.dumps(locations, separators=(',', ':'))+(',' if i+1 < len(entries) else ''))
    packed += ['  }', '}']
    result[source / 'localization/index.json'] = '\n'.join(packed) + '\n'
    groups = {}
    for key in localization['entries']:
        group = '_'.join(key.split('_')[:2])
        groups.setdefault(group, []).append(key)
    lines = ['# LANGUAGE index', '',
             'Generated from [../LANGUAGE](../LANGUAGE); shared bilingual text remains authoritative there.',
             f'SHA-256: `{localization["sha256"]}`. Locations include every definition; the last one per language wins.',
             'Run `python build_dialogue_index.py check` before using locations.', '',
             'Use `python build_dialogue_index.py find TERM` to locate keys, then',
             '`python build_dialogue_index.py read KEY` to read only its English and Spanish source lines.',
             'Both commands reject stale indexes. `npc NAME --conversation ID --page NAME`',
             'locates the keys used by one dialogue page through the [NPC index](../dialogues/INDEX.md).',
             'The machine-readable [index.json](index.json) stores inclusive line ranges for all keys,',
             'including shared UI/system keys and dynamically selected text.', '',
             '| Key group | Keys | First key | Last key |', '| --- | ---: | --- | --- |']
    for group, keys in sorted(groups.items()):
        lines.append(f'| {group} | {len(keys)} | {keys[0]} | {keys[-1]} |')
    result[source / 'localization/INDEX.md'] = '\n'.join(lines) + '\n'
    return result


def validate(root=ROOT, source=None):
    source = source or root / 'src'
    try:
        problems = []
        for path, text in outputs(root, source).items():
            if not path.is_file() or path.read_bytes() != text.encode('utf-8'):
                problems.append(f'{path.relative_to(source)}: stale/missing; run python build_dialogue_index.py build')
        info = (source / 'MAPINFO').read_text(encoding='utf-8')
        if re.findall(r'\bAddDialogues\s*=\s*"([^"]+)"', info) != ['dialogues/runtime.usdf']:
            problems.append('MAPINFO must load only dialogues/runtime.usdf')
        return problems
    except (OSError, ValueError, KeyError, TypeError) as exc:
        return [f'Dialogue/localization index: {exc}']


def main():
    sys.stdout.reconfigure(encoding='utf-8')
    sys.stderr.reconfigure(encoding='utf-8')
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=ROOT)
    parser.add_argument('--source', type=Path)
    sub = parser.add_subparsers(dest='command', required=True)
    sub.add_parser('build')
    sub.add_parser('check')
    find = sub.add_parser('find'); find.add_argument('term')
    read = sub.add_parser('read'); read.add_argument('key')
    npc = sub.add_parser('npc'); npc.add_argument('name')
    npc.add_argument('--conversation', type=int); npc.add_argument('--page')
    args = parser.parse_args()
    source = (args.source or args.root / 'src').resolve()
    try:
        if args.command == 'build':
            generated = outputs(args.root, source)
            for path, text in generated.items():
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(text, encoding='utf-8', newline='\n')
            print(f'Generated {len(generated)} dialogue/localization artifacts.')
            return 0
        problems = validate(args.root, source)
        if problems:
            raise ValueError('\n'.join(problems))
        if args.command == 'check':
            print('Dialogue sources, ordered runtime and localization index are current.')
            return 0
        entries = json.loads((source / 'localization/index.json').read_text(encoding='utf-8'))['entries']
        if args.command == 'find':
            matches = [key for key in entries if args.term.upper() in key]
            for key in matches:
                print(key, json.dumps({lang: entries[key][lang] for lang in ('enu','default','es') if lang in entries[key]}))
            return 0 if matches else 1
        if args.command == 'read':
            lines = (source / 'LANGUAGE').read_text(encoding='utf-8').splitlines()
            key = args.key.lstrip('$')
            if key not in entries:
                raise ValueError(f'Unknown localization key: {key}')
            for lang in ('enu' if 'enu' in entries[key] else 'default', 'es'):
                for start, end in entries[key].get(lang, []):
                    print(f'LANGUAGE [{lang}] {start}-{end}')
                    print('\n'.join(lines[start-1:end]))
        if args.command == 'npc':
            _, conversations = load_catalogue(source)
            selected = [b for b in conversations if b['owner']['name'] == args.name and
                        (args.conversation is None or b['id'] == args.conversation)]
            if not selected:
                raise ValueError('No matching NPC/conversation')
            found_page = False
            for block in selected:
                print(f'{block["owner"]["path"]}:{block["line"]}-{block["end_line"]} conversation {block["id"]}')
                for page in block['pages']:
                    name = field(page, 'pagename') or '(unnamed)'
                    if args.page and args.page != name:
                        continue
                    found_page = True
                    print(f'  page {name}: {block["line"]+page["line"]-1}-{block["line"]+page["end_line"]-1}')
                    print('  keys: '+', '.join(localized_keys(page)))
            if args.page and not found_page:
                raise ValueError(f'Unknown page: {args.page}')
        return 0
    except (OSError, ValueError, KeyError, TypeError) as exc:
        print(str(exc), file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())

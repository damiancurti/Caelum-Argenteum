"""Deterministic lexical inventory, not a compiler or exhaustive call graph.

Declarations and source locations support the manually reviewed ownership table.
Non-transient fields are serialization candidates, not proof of engine save output.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent


def mask(text):
    return re.sub(r'//[^\n]*|/\*[\s\S]*?\*/|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'',
                  lambda m: re.sub(r'[^\n]', ' ', m.group()), text)


def close_brace(text, start):
    depth = 1
    for i in range(start + 1, len(text)):
        depth += (text[i] == '{') - (text[i] == '}')
        if depth == 0:
            return i
    raise ValueError('Unbalanced source')


def declarations(text):
    clean = mask(text)
    result = []
    for match in re.finditer(r'\b(class|struct)\s+(\w+)([^;{}]*)\{', clean):
        start, end = match.end() - 1, close_brace(clean, match.end() - 1)
        fields, methods = [], []
        cursor = start + 1
        member_start = cursor
        while cursor < end:
            if clean[cursor] == ';':
                declaration = ' '.join(clean[member_start:cursor].split())
                if declaration and not re.match(r'^(const|enum|property|flagdef)\b', declaration):
                    fields.append({'declaration': declaration,
                                   'line': text.count('\n', 0, member_start) + 1,
                                   'transient_or_ui': bool(re.search(r'\b(transient|ui)\b', declaration))})
                member_start = cursor + 1
            elif clean[cursor] == '{':
                header = ' '.join(clean[member_start:cursor].split())
                method = re.search(r'(\w+)\s*\(', header)
                finish = close_brace(clean, cursor)
                if method and not header.startswith(('Default', 'States', 'enum')):
                    methods.append({'name': method.group(1), 'signature': header,
                                    'line': text.count('\n', 0, member_start) + 1,
                                    'end_line': text.count('\n', 0, finish) + 1,
                                    'body_start': cursor, 'body_end': finish})
                cursor = finish
                member_start = cursor + 1
            cursor += 1
        result.append({'name': match.group(2), 'kind': match.group(1),
                       'base': ' '.join(match.group(3).split()),
                       'line': text.count('\n', 0, match.start()) + 1,
                       'fields': fields, 'methods': methods})
    return result


def generate(ref=None):
    if ref:
        names = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', ref, 'src'], cwd=ROOT, text=True).splitlines()
        read = lambda name: subprocess.check_output(['git', 'show', f'{ref}:{name}'], cwd=ROOT)
    else:
        names = [p.relative_to(ROOT).as_posix() for p in (ROOT / 'src').rglob('*') if p.is_file()]
        read = lambda name: (ROOT / name).read_bytes()
    files = {}
    for name in sorted(n for n in names if n.endswith('.zs') or n == 'src/ZSCRIPT'):
        raw = read(name)
        text = raw.decode('utf-8-sig')
        files[name] = {'sha256': hashlib.sha256(raw).hexdigest(),
                       'lines': len(text.splitlines()),
                       'includes': re.findall(r'#include\s+"([^"]+)"', text),
                       'classes': declarations(text)}
    reachable = set()
    pending = ['src/ZSCRIPT']
    while pending:
        name = pending.pop()
        if name in reachable:
            continue
        reachable.add(name)
        for include in files[name]['includes']:
            target = 'src/' + include
            if target not in files:
                target = (Path(name).parent / include).as_posix()
            if target not in files:
                raise ValueError(f'Unresolved include: {name}: {include}')
            pending.append(target)
    symbols = {c['name']: name for name, entry in files.items() if name in reachable for c in entry['classes']}
    for name, entry in files.items():
        entry['included'] = name in reachable
        text = mask(read(name).decode('utf-8-sig'))
        entry['lexical_dependencies'] = sorted({symbols[word] for word in set(re.findall(r'\b\w+\b', text)) if word in symbols and symbols[word] != name})
        for cls in entry['classes']:
            for method in cls['methods']:
                method.pop('body_start')
                method.pop('body_end')
    return {'reference': ref or 'working tree',
            'limitations': ['Lexical class references are not call edges.',
                            'Fields are declared serialization candidates; native/inherited fields and object reachability require engine/source review.',
                            'Source inventory includes files not necessarily reachable from src/ZSCRIPT.'],
            'included_files': len(reachable), 'files': files}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ref')
    parser.add_argument('--output', default='SOURCE_AUDIT.json')
    args = parser.parse_args()
    data = generate(args.ref)
    (HERE / args.output).write_text(json.dumps(data, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    print(f"Wrote {args.output}: {len(data['files'])} source files")

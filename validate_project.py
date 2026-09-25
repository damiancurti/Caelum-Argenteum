#!/usr/bin/env python3
"""Check current documentation, localization and resources without modifying files."""
from pathlib import Path
import argparse
import json
import re
import struct

from build_document_index import (
    INDEX_NAME as DOC_INDEX_NAME,
    THRESHOLD_WORDS,
    inventory_docs,
    parse_index_meta,
    read_utf8 as read_doc,
    sha256 as doc_sha256,
    word_count as doc_word_count,
)

CANONICAL = {'PROJECT.md', 'SYSTEMS.md', 'MAP01.txt', 'ASSETS.md', 'HISTORY.md'}
WORKING = {'CONTEXT.md', 'TASKS.md'}
DOCUMENTS = CANONICAL | WORKING
ANCILLARY = {'GZDOOM_DEVELOPMENT.md', 'KNOWN_PITFALLS.md'}
ALLOWED_DOCS = DOCUMENTS | ANCILLARY | {DOC_INDEX_NAME}

NUMERIC_VERSION_RE = re.compile(r'(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)[a-z]?\Z')
DIAGNOSTICS = ('src/caelum/world/CaelumPhysicalHazards.zs',
               'src/caelum/world/CaelumSewerMaze.zs')

AUDIO_INVENTORY_RE = re.compile(
    r'(?:contiene\s+(\d+)\s+archivos de runtime'
    r'|contains\s+(\d+)\s+runtime(?: audio)? files)'
)

def index_problems(root):
    """Report stale or missing coverage for the generated document index."""
    index_path = root / 'docs' / DOC_INDEX_NAME
    if not index_path.is_file():
        return ['docs/DOCUMENT_INDEX.md: missing generated index; run python build_document_index.py']
    try:
        meta = parse_index_meta(index_path.read_text(encoding='utf-8-sig'))
    except (OSError, UnicodeError) as exc:
        return [f'docs/DOCUMENT_INDEX.md: cannot read UTF-8 file: {exc}']
    if not meta:
        return ['docs/DOCUMENT_INDEX.md: missing or invalid DOCUMENT_INDEX_META block']
    indexed = {entry['path']: entry for entry in meta.get('documents', [])}
    current = {}
    for path in inventory_docs(root):
        relative = path.relative_to(root / 'docs').as_posix()
        words = doc_word_count(read_doc(path))
        if words > THRESHOLD_WORDS:
            current[relative] = {'words': words, 'sha256': doc_sha256(path)}
    if set(indexed) != set(current):
        return ['DOCUMENT_INDEX.md: coverage mismatch; indexed ' + ', '.join(sorted(indexed)) +
                ' but expected ' + ', '.join(sorted(current)) + '; run python build_document_index.py']
    problems = []
    for relative in current:
        if indexed[relative]['sha256'] != current[relative]['sha256']:
            problems.append(f'DOCUMENT_INDEX.md: stale SHA-256 for {relative}; run python build_document_index.py')
        elif indexed[relative]['words'] != current[relative]['words']:
            problems.append(f'DOCUMENT_INDEX.md: stale word count for {relative}; run python build_document_index.py')
    return problems

def validate(root):
    errors = []
    def check(condition, message):
        if not condition:
            errors.append(message)

    def read(relative):
        try:
            return (root / relative).read_text(encoding='utf-8-sig')
        except (OSError, UnicodeError) as exc:
            check(False, f'{relative}: cannot read UTF-8 file: {exc}')
            return ''

    def current_version(text, label, name):
        # Only the opening header is authoritative; release history is unrestricted.
        header = text[:1000].replace('**', '')
        markers = re.findall(r'^' + re.escape(label) + r'\s*(\S+)', header, re.M)
        check(len(markers) == 1, f'{name}: require exactly one opening "{label}" header.')
        value = markers[0] if markers else ''
        if value.endswith('.'):
            value = value[:-1]
        check(bool(NUMERIC_VERSION_RE.fullmatch(value)),
              f'{name}: current version {value!r} must use numeric MAJOR.MINOR.PATCH.')
        return value

    def links(text, path):
        targets = re.findall(r'\]\(([^)]+)\)', text)
        for target in targets:
            if not re.match(r'^[a-z]+:', target) and not target.startswith('#'):
                check((path.parent / target.split('#')[0]).exists(),
                      f'{path.relative_to(root)}: missing link target {target}')
        return targets

    readme = read('README.md')
    version = current_version(readme, 'Current release:', 'README.md')
    actual_docs = {p.relative_to(root/'docs').as_posix() for p in (root/'docs').rglob('*') if p.is_file()}
    check(actual_docs == ALLOWED_DOCS, f'docs must contain exactly {sorted(ALLOWED_DOCS)}; found {sorted(actual_docs)}')
    for heading in ('## Implemented', '## Planned', '## Pending validation'):
        check(heading in readme, f'README: missing {heading}')
    # Every canonical/working document and AGENTS declares a version. Ancillary
    # guides without this header inherit README's release (see AGENTS.md).
    for relative in ['AGENTS.md'] + ['docs/' + name for name in sorted(DOCUMENTS)]:
        text = read(relative)
        declared = current_version(text, 'Documentation version:', relative)
        check(declared == version, f'{relative}: current version {declared!r} differs from README {version!r}.')
        check('VALIDATION_RESULT_PLACEHOLDER' not in text, f'{relative}: unfinished validation placeholder')
        if relative != 'docs/HISTORY.md':
            links(text, root / relative)
    # Ancillary engineering guides and the generated index inherit README's
    # release. Validate their existence, UTF-8 readability and local links.
    for name in sorted(ANCILLARY):
        links(read('docs/' + name), root / ('docs/' + name))
    index_text = read('docs/' + DOC_INDEX_NAME)
    links(index_text, root / ('docs/' + DOC_INDEX_NAME))
    for problem in index_problems(root):
        check(False, problem)
    for relative in DIAGNOSTICS:
        markers = re.findall(r'\[Caelum ([^\]]+)\]', read(relative))
        check(bool(markers) and all(v == version for v in markers),
              f'{relative}: diagnostic release labels must match README {version!r}.')
    readme_links = links(readme, root / 'README.md')
    for target in ('pending_test.txt', 'docs/HISTORY.md'):
        check(target in readme_links, f'README: add a direct Markdown link to {target}.')
    check((root / 'pending_test.txt').is_file(), 'Missing root pending_test.txt; keep it tracked even when empty.')
    if (root / 'pending_test.txt').is_file():
        read('pending_test.txt')

    sndinfo = (root/'src/SNDINFO').read_text(encoding='utf-8-sig')
    definitions = dict(re.findall(r'^([\w/]+)\s*=\s*"([^"]+)"', sndinfo, re.M))
    aliases = dict(re.findall(r'^\$alias\s+(\S+)\s+(\S+)', sndinfo, re.M))
    for name, path in definitions.items():
        check((root/'src'/path).is_file(), f'SNDINFO: missing {path} ({name})')
    native = ['activate','backup','prompt','cursor','change','invalid','dismiss','choose','clear','advance','quit1','quit2']
    native = ['menu/'+name for name in native] + ['switches/normbutn','switches/exitbutn']
    for name in native:
        target, visited = name, set()
        while target in aliases and target not in visited:
            visited.add(target)
            target = aliases[target]
        check(target.startswith('caelum/') and target in definitions,
              f'{name}: does not resolve to a Caelum resource')
    mapinfo = (root/'src/MAPINFO').read_text(encoding='utf-8-sig')
    title = re.search(r'TitleMusic\s*=\s*"([^"]+)"', mapinfo)
    check(title is not None and (root/'src'/title.group(1)).is_file(), 'TitleMusic: missing file')
    quit_sound = re.search(r'QuitSound\s*=\s*"([^"]+)"', mapinfo)
    check(quit_sound is not None and quit_sound.group(1) in definitions, 'QuitSound: alias has no project definition')
    chat = re.search(r'ChatSound\s*=\s*"([^"]+)"', mapinfo)
    check(chat is not None and chat.group(1) == 'caelum/ui/dialogue_open', 'ChatSound: must use the selected dialogue-opening cue')
    check('$singular caelum/ui/dialogue_open' in sndinfo, 'Missing protection against overlapping dialogue phrases')
    check('CaelumMenuAudio' in mapinfo and (root/'src/caelum/ui/CaelumMenuAudio.zs').is_file(), 'Missing title-screen audio observer')
    code = '\n'.join(p.read_text(encoding='utf-8-sig') for p in (root/'src/caelum').rglob('*.zs'))
    check('PlayDialogueOpenSound' not in code, 'Duplicate manual dialogue-opening call remains')
    check('tools\\build_pk3.ps1' not in (root/'run_dev.bat').read_text(), 'run_dev still depends on the retired tools directory')
    check((root/'build_dev.ps1').is_file(), 'Missing root build_dev.ps1')
    check((root/'build_document_index.py').is_file(), 'Missing root build_document_index.py')
    for name in ('generate_environment_models.py', 'generate_mineral_veins.py', 'generate_stash_models.py', 'generate_station_models.py'):
        check((root/'assets/generators'/name).is_file(), 'Missing source generator: '+name)
    # An incorrect locale can compile while leaving a conversation in English.
    # Keep checking the Spanish Caella keys independently of documentation language.
    language = (root/'src/LANGUAGE').read_text(encoding='utf-8-sig')
    localized = {'default': set(), 'es': set()}
    for section, body in re.findall(r'^\[([^\]]+)\]\s*\n(.*?)(?=^\[|\Z)', language, re.M | re.S):
        keys = set(re.findall(r'^(CA_\w+)\s*=', body, re.M))
        for locale in localized:
            if locale in section.split():
                localized[locale].update(keys)
    magic_keys = {key for key in localized['default'] if key.startswith('CA_DLG_M01_MAGIC_')}
    check(bool(magic_keys), 'LANGUAGE: missing Caella keys')
    check(magic_keys <= localized['es'], 'LANGUAGE: missing Spanish (es) Caella translations: '+', '.join(sorted(magic_keys-localized['es'])))
    # OBJ files alone do not activate models: each concrete class needs a binding,
    # including class names retained for compatibility.
    station_source = (root/'src/caelum/crafting/CaelumCraftingStation.zs').read_text()
    station_classes = set(re.findall(r'^class (Caelum\w+Station)\s*:', station_source, re.M)) - {'CaelumCraftingStation'}
    modeldef = (root/'src/MODELDEF').read_text()
    station_bindings = set()
    station_models = set()
    for actor, body in re.findall(r'^Model\s+(\w+)\s*\{([^}]+)\}', modeldef, re.M):
        if actor not in station_classes:
            continue
        station_bindings.add(actor)
        path = re.search(r'\bPath\s+"([^"]+)"', body)
        model = re.search(r'\bModel\s+0\s+"([^"]+)"', body)
        check(path is not None and model is not None, 'MODELDEF: incomplete definition for '+actor)
        if path is None or model is None:
            continue
        resource = root/'src'/path.group(1)/model.group(1)
        check(resource.is_file(), 'MODELDEF: missing '+str(resource.relative_to(root)))
        station_models.add(resource)
    check(station_classes == station_bindings, 'MODELDEF: stations without model bindings: '+', '.join(sorted(station_classes-station_bindings)))
    for resource in station_models:
        if resource.is_file():
            for material in re.findall(r'^usemtl\s+(\S+)', resource.read_text(), re.M):
                check((root/'src'/material).is_file(), resource.name+': missing material '+material)
    for include in re.findall(r'#include\s+"([^"]+)"', (root/'src/ZSCRIPT').read_text()):
        check((root/'src'/include).is_file(), 'ZSCRIPT: missing include '+include)
    # The last Ogg page stores the final Vorbis sample position.
    cue = root/'src/sounds/caelum/ui/ca_dialogue_open.ogg'
    if cue.exists():
        data, offset, last_granule = cue.read_bytes(), 0, 0
        while offset < len(data):
            if data[offset:offset+4] != b'OggS' or offset+27 > len(data):
                errors.append('Dialogue cue: invalid Ogg container')
                break
            last_granule = struct.unpack_from('<Q', data, offset+6)[0]
            segments = data[offset+26]
            offset += 27 + segments + sum(data[offset+27:offset+27+segments])
        ident = data.find(b'\x01vorbis')
        sample_rate = struct.unpack_from('<I', data, ident+12)[0] if ident >= 0 else 0
        check(sample_rate == 48000 and last_granule == 134400, 'The dialogue-opening cue must retain 134400 samples at 48000 Hz')
    else:
        errors.append('Missing dialogue cue')
    audio_count = sum(p.suffix.lower() in ('.ogg','.mp3') for p in (root/'src').rglob('*') if p.is_file())
    assets = (root/'docs/ASSETS.md').read_text(encoding='utf-8-sig')
    count = re.search(AUDIO_INVENTORY_RE, assets)
    inventory = int(count.group(1) or count.group(2)) if count else None
    check(inventory == audio_count, 'ASSETS.md: update the runtime audio inventory count')

    # Check contributor premises when the file can be read.
    agents = root/'AGENTS.md'
    premise_numbers = set()
    if agents.exists():
        text = agents.read_text(encoding='utf-8-sig')
        premise_numbers = {int(n) for n in re.findall(
            r'(?:Premisa|Premise)s?\s+([0-9]{1,2})(?:\s+a\s+[0-9]{1,2})?\s*(?:[.:-]|$)', text, re.I)}
        if not premise_numbers:
            premise_numbers = {int(n) for n in re.findall(r'^([0-9]{1,2})\.\s', text, re.M)}
        check(bool(premise_numbers), 'AGENTS.md: no numbered premises found')

    context = root/'docs'/'CONTEXT.md'
    context_words = 0
    if context.exists():
        text = context.read_text(encoding='utf-8-sig')
        context_words = len(text.split())
        check(context_words < 2500, f'CONTEXT.md: exceeds 2500 words ({context_words})')
    else:
        check(False, 'Missing docs/CONTEXT.md')

    check((root/'docs'/'TASKS.md').exists(), 'Missing docs/TASKS.md')
    check((root/'.github'/'ISSUE_TEMPLATE'/'tarea.md').exists(), 'Missing .github/ISSUE_TEMPLATE/tarea.md')

    return {'version':version, 'documents':len(actual_docs), 'audio_files':audio_count,
            'station_models':len(station_models), 'spanish_caella_keys':len(magic_keys),
            'premise_numbers':sorted(premise_numbers), 'context_words':context_words,
            'errors':errors}

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('root', nargs='?', type=Path, default=Path(__file__).resolve().parent,
                        help='Repository root (defaults to the directory containing this script).')
    args = parser.parse_args()
    try:
        result = validate(args.root.resolve())
    except (OSError, UnicodeError, struct.error) as exc:
        result = {'errors': [f'Cannot validate repository input: {exc}. Restore the named file from the complete checkout.']}
    print(json.dumps(result, ensure_ascii=False, indent=2))
    raise SystemExit(1 if result['errors'] else 0)

if __name__ == '__main__':
    main()

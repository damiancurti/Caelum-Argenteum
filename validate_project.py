#!/usr/bin/env python3
"""Comprueba documentación, traducciones y recursos sin modificar archivos."""
from pathlib import Path
import argparse
import json
import re
import struct

CANONICAL = {'PROJECT.md', 'SYSTEMS.md', 'MAP01.txt', 'ASSETS.md', 'HISTORY.md'}
WORKING = {'CONTEXT.md', 'TASKS.md'}
DOCUMENTS = CANONICAL | WORKING

VERSION_RE = re.compile(
    r'(?:Versión documental|Document(?:ary)? version)\s*:\s*'
    r'([0-9]+\.[0-9]+\.[0-9]+(?:[a-z]+[0-9]*)?)'
)

AUDIO_INVENTORY_RE = re.compile(
    r'(?:contiene\s+(\d+)\s+archivos de runtime'
    r'|contains\s+(\d+)\s+runtime(?: audio)? files)'
)

def validate(root):
    errors = []
    def check(condition, message):
        if not condition:
            errors.append(message)

    readme = (root / 'README.md').read_text(encoding='utf-8-sig')
    match = re.search(r'Current release: ([0-9]+\.[0-9]+\.[0-9]+(?:[a-z]+[0-9]*)?)\.', readme)
    check(match is not None, 'README: falta Current release.')
    version = match.group(1) if match else ''
    actual_docs = {p.relative_to(root/'docs').as_posix() for p in (root/'docs').rglob('*') if p.is_file()}
    check(actual_docs == DOCUMENTS, f'docs debe contener exactamente {sorted(DOCUMENTS)}; encontrado {sorted(actual_docs)}')
    for heading in ('## Implemented', '## Planned', '## Pending validation'):
        check(heading in readme, f'README: falta {heading}')
    for name in sorted(CANONICAL):
        path = root/'docs'/name
        if not path.exists():
            continue
        text = path.read_text(encoding='utf-8-sig')
        header = re.search(VERSION_RE, text[:1000])
        check(header is not None and header.group(1) == version, f'{name}: versión desactualizada')
        check('VALIDATION_RESULT_PLACEHOLDER' not in text, f'{name}: validación sin completar')
        if name == 'HISTORY.md':
            continue
        for target in re.findall(r'\]\(([^)]+)\)', text):
            if not re.match(r'^[a-z]+:', target) and not target.startswith('#'):
                check((path.parent/target.split('#')[0]).exists(), f'{name}: enlace inexistente {target}')
    for target in re.findall(r'\]\(([^)]+)\)', readme):
        if not re.match(r'^[a-z]+:', target) and not target.startswith('#'):
            check((root/target.split('#')[0]).exists(), f'README: enlace inexistente {target}')

    sndinfo = (root/'src/SNDINFO').read_text(encoding='utf-8-sig')
    definitions = dict(re.findall(r'^([\w/]+)\s*=\s*"([^"]+)"', sndinfo, re.M))
    aliases = dict(re.findall(r'^\$alias\s+(\S+)\s+(\S+)', sndinfo, re.M))
    for name, path in definitions.items():
        check((root/'src'/path).is_file(), f'SNDINFO: falta {path} ({name})')
    native = ['activate','backup','prompt','cursor','change','invalid','dismiss','choose','clear','advance','quit1','quit2']
    native = ['menu/'+name for name in native] + ['switches/normbutn','switches/exitbutn']
    for name in native:
        target, visited = name, set()
        while target in aliases and target not in visited:
            visited.add(target)
            target = aliases[target]
        check(target.startswith('caelum/') and target in definitions,
              f'{name}: no resuelve a un recurso de Caelum')
    mapinfo = (root/'src/MAPINFO').read_text(encoding='utf-8-sig')
    title = re.search(r'TitleMusic\s*=\s*"([^"]+)"', mapinfo)
    check(title is not None and (root/'src'/title.group(1)).is_file(), 'TitleMusic: archivo inexistente')
    quit_sound = re.search(r'QuitSound\s*=\s*"([^"]+)"', mapinfo)
    check(quit_sound is not None and quit_sound.group(1) in definitions, 'QuitSound: alias sin definición propia')
    chat = re.search(r'ChatSound\s*=\s*"([^"]+)"', mapinfo)
    check(chat is not None and chat.group(1) == 'caelum/ui/dialogue_open', 'ChatSound: debe usar una sola frase de arpa nativa')
    check('$singular caelum/ui/dialogue_open' in sndinfo, 'Falta la proteccion de frases superpuestas')
    check('CaelumMenuAudio' in mapinfo and (root/'src/caelum/ui/CaelumMenuAudio.zs').is_file(), 'Falta el observador de audio de portada')
    code = '\n'.join(p.read_text(encoding='utf-8-sig') for p in (root/'src/caelum').rglob('*.zs'))
    check('PlayDialogueOpenSound' not in code, 'Quedo una llamada duplicada al arpa')
    check('tools\\build_pk3.ps1' not in (root/'run_dev.bat').read_text(), 'run_dev aun depende de tools')
    check((root/'build_dev.ps1').is_file(), 'Falta el constructor en raiz')
    for name in ('generate_environment_models.py', 'generate_mineral_veins.py', 'generate_stash_models.py', 'generate_station_models.py'):
        check((root/'assets/generators'/name).is_file(), 'Falta un generador fuente: '+name)
    # Una sección con un código de idioma distinto puede compilar y aun así
    # dejar una conversación entera en inglés. Comprobar las claves de Caella.
    language = (root/'src/LANGUAGE').read_text(encoding='utf-8-sig')
    localized = {'default': set(), 'es': set()}
    for section, body in re.findall(r'^\[([^\]]+)\]\s*\n(.*?)(?=^\[|\Z)', language, re.M | re.S):
        keys = set(re.findall(r'^(CA_\w+)\s*=', body, re.M))
        for locale in localized:
            if locale in section.split():
                localized[locale].update(keys)
    magic_keys = {key for key in localized['default'] if key.startswith('CA_DLG_M01_MAGIC_')}
    check(bool(magic_keys), 'LANGUAGE: faltan las claves de Caella')
    check(magic_keys <= localized['es'], 'LANGUAGE: faltan traducciones es de Caella: '+', '.join(sorted(magic_keys-localized['es'])))
    # Los OBJ por sí solos no activan los modelos: cada clase concreta necesita
    # su asociación, incluidos los nombres conservados por compatibilidad.
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
        check(path is not None and model is not None, 'MODELDEF: definición incompleta de '+actor)
        if path is None or model is None:
            continue
        resource = root/'src'/path.group(1)/model.group(1)
        check(resource.is_file(), 'MODELDEF: falta '+str(resource.relative_to(root)))
        station_models.add(resource)
    check(station_classes == station_bindings, 'MODELDEF: estaciones sin modelo: '+', '.join(sorted(station_classes-station_bindings)))
    for resource in station_models:
        if resource.is_file():
            for material in re.findall(r'^usemtl\s+(\S+)', resource.read_text(), re.M):
                check((root/'src'/material).is_file(), resource.name+': falta el material '+material)
    for include in re.findall(r'#include\s+"([^"]+)"', (root/'src/ZSCRIPT').read_text()):
        check((root/'src'/include).is_file(), 'ZSCRIPT: include inexistente '+include)
    # Vorbis conserva la posición final en muestras en la última página Ogg.
    cue = root/'src/sounds/caelum/ui/ca_dialogue_open.ogg'
    if cue.exists():
        data, offset, last_granule = cue.read_bytes(), 0, 0
        while offset < len(data):
            if data[offset:offset+4] != b'OggS' or offset+27 > len(data):
                errors.append('Recorte de diálogo: contenedor Ogg inválido')
                break
            last_granule = struct.unpack_from('<Q', data, offset+6)[0]
            segments = data[offset+26]
            offset += 27 + segments + sum(data[offset+27:offset+27+segments])
        ident = data.find(b'\x01vorbis')
        sample_rate = struct.unpack_from('<I', data, ident+12)[0] if ident >= 0 else 0
        check(sample_rate == 44100 and last_granule == 113400, 'La frase de arpa debe conservar 113400 muestras a 44100 Hz')
    else:
        errors.append('Falta el recorte de diálogo')
    audio_count = sum(p.suffix.lower() in ('.ogg','.mp3') for p in (root/'src').rglob('*') if p.is_file())
    assets = (root/'docs/ASSETS.md').read_text(encoding='utf-8-sig')
    count = re.search(AUDIO_INVENTORY_RE, assets)
    inventory = int(count.group(1) or count.group(2)) if count else None
    check(inventory == audio_count, 'ASSETS.md: actualizar el inventario de audio')

    # Comprobaciones opcionales: solo se ejecutan si el archivo existe.
    agents = root/'AGENTS.md'
    premise_numbers = set()
    if agents.exists():
        text = agents.read_text(encoding='utf-8-sig')
        premise_numbers = {int(n) for n in re.findall(
            r'(?:Premisa|Premise)s?\s+([0-9]{1,2})(?:\s+a\s+[0-9]{1,2})?\s*(?:[.:-]|$)', text, re.I)}
        if not premise_numbers:
            premise_numbers = {int(n) for n in re.findall(r'^([0-9]{1,2})\.\s', text, re.M)}
        check(bool(premise_numbers), 'AGENTS.md: no se detectaron premisas numeradas')

    context = root/'docs'/'CONTEXT.md'
    context_words = 0
    if context.exists():
        text = context.read_text(encoding='utf-8-sig')
        context_words = len(text.split())
        check(context_words < 2500, f'CONTEXT.md: excede 2500 palabras ({context_words})')
    else:
        check(False, 'Falta docs/CONTEXT.md')

    check((root/'docs'/'TASKS.md').exists(), 'Falta docs/TASKS.md')
    check((root/'.github'/'ISSUE_TEMPLATE'/'tarea.md').exists(), 'Falta .github/ISSUE_TEMPLATE/tarea.md')

    return {'version':version, 'documents':len(actual_docs), 'audio_files':audio_count,
            'station_models':len(station_models), 'spanish_caella_keys':len(magic_keys),
            'premise_numbers':sorted(premise_numbers), 'context_words':context_words,
            'errors':errors}

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('root', nargs='?', type=Path, default=Path(__file__).resolve().parent)
    args = parser.parse_args()
    result = validate(args.root)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    raise SystemExit(1 if result['errors'] else 0)

if __name__ == '__main__':
    main()

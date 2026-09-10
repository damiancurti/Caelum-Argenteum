#!/usr/bin/env python3
"""Comprueba documentación canónica y referencias de audio sin modificar archivos."""
from pathlib import Path
import argparse
import json
import re
import struct

DOCUMENTS = {'PROJECT.md', 'SYSTEMS.md', 'MAP01.txt', 'ASSETS.md', 'HISTORY.md'}

def validate(root):
    errors = []
    def check(condition, message):
        if not condition:
            errors.append(message)

    readme = (root / 'README.md').read_text(encoding='utf-8-sig')
    match = re.search(r'Current release: ([0-9]+\.[0-9]+\.[0-9]+[a-z]?)\.', readme)
    check(match is not None, 'README: falta Current release.')
    version = match.group(1) if match else ''
    actual_docs = {p.relative_to(root/'docs').as_posix() for p in (root/'docs').rglob('*') if p.is_file()}
    check(actual_docs == DOCUMENTS, f'docs debe contener sólo {sorted(DOCUMENTS)}; encontrado {sorted(actual_docs)}')
    for heading in ('## Implemented', '## Planned', '## Pending validation'):
        check(heading in readme, f'README: falta {heading}')
    for name in sorted(DOCUMENTS):
        path = root/'docs'/name
        if not path.exists():
            continue
        text = path.read_text(encoding='utf-8-sig')
        check(f'Versión documental: {version}' in text[:1000], f'{name}: versión desactualizada')
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
    check('CaelumMenuAudio' in mapinfo and (root/'src/caelum/ui/CaelumMenuAudio.zs').is_file(), 'Falta el bucle de portada')
    code = '\n'.join(p.read_text(encoding='utf-8-sig') for p in (root/'src/caelum').rglob('*.zs'))
    check('PlayDialogueOpenSound' not in code, 'Quedo una llamada duplicada al arpa')
    check('tools\\build_pk3.ps1' not in (root/'run_dev.bat').read_text(), 'run_dev aun depende de tools')
    check((root/'build_dev.ps1').is_file(), 'Falta el constructor en raiz')
    for name in ('generate_environment_models.py', 'generate_mineral_veins.py', 'generate_stash_models.py'):
        check((root/'assets/generators'/name).is_file(), 'Falta un generador fuente: '+name)
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
    count = re.search(r'contiene (\d+) archivos de runtime', assets)
    check(count is not None and int(count.group(1)) == audio_count, 'ASSETS.md: actualizar el inventario de audio')
    return {'version':version, 'documents':len(actual_docs), 'audio_files':audio_count, 'errors':errors}

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('root', nargs='?', type=Path, default=Path(__file__).resolve().parent)
    args = parser.parse_args()
    result = validate(args.root)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    raise SystemExit(1 if result['errors'] else 0)

if __name__ == '__main__':
    main()

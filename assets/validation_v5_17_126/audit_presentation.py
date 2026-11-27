"""Audit retained glyphs, localization coverage, UI image references and notices."""
from pathlib import Path
import hashlib,io,json,re,subprocess,sys,tarfile
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT))
import build_dialogue_index as dialogue
from assets.generators.generate_presentation_465 import generate


def language_values():
    path=ROOT/'src/LANGUAGE';lines=path.read_text(encoding='utf-8-sig').splitlines()
    index=dialogue.language_index(path)['entries'];values={}
    for key,languages in index.items():
        values[key]={}
        for language,ranges in languages.items():
            first,last=ranges[-1];source='\n'.join(lines[first-1:last])
            values[key][language]=''.join(dialogue.value(token[0]) for token in dialogue.tokens(source) if token[0].startswith('"'))
    return values


def locale_probe():
    repair=json.loads(Path(__file__).with_name('evidence').joinpath('localization-repair.json').read_text(encoding='utf8'))
    keys=[row['key'] for row in repair['general_spanish_aliases']]+repair['physics_keys']
    values=language_values();keys+=sorted(key for key in values if key.startswith('CA_CREDITS_'))
    lines=['class CA465LocaleProbe : Object ui { static int Check(bool spanish) { int errors=0;']
    for key in keys:
        es=json.dumps(values[key]['es'],ensure_ascii=False);en=json.dumps(values[key].get('enu',values[key].get('default')),ensure_ascii=False)
        lines.append(f'if(StringTable.Localize("{key}",false)!=(spanish?{es}:{en})) {{ errors++; Console.Printf("CA465 LOCALE FAIL {key}"); }}')
    lines+=['return errors; } }']
    return '\n'.join(lines).encode('utf8')


def main():
    baseline='7923b0d14901386260efce2df6db34ac51cfc985';errors=[]
    output=generate()
    for name,blob in output.items():
        if not (ROOT/name).exists() or (ROOT/name).read_bytes()!=blob:errors.append('Stale '+name)
    retained=[]
    archive=subprocess.check_output(['git','archive',baseline,'src/fonts'],cwd=ROOT)
    with tarfile.open(fileobj=io.BytesIO(archive)) as files:
        for member in files:
            if not member.isfile():continue
            name=member.name;old=files.extractfile(member).read()
            if (ROOT/name).read_bytes()!=old:errors.append('Changed original '+name)
            retained.append({'path':name,'sha256':hashlib.sha256(old).hexdigest()})
    values=language_values()
    missing=[key for key,row in values.items() if key.startswith('CA_') and ('es' not in row or not ('enu' in row or 'default' in row))]
    errors.extend('Missing ES/EN '+key for key in missing)
    # Static coverage checks actual authored text; control escape bytes are ASCII.
    used={ord(ch) for row in values.values() for text in row.values() for ch in text if ord(ch)>32}
    font_coverage={}
    for directory in sorted((ROOT/'src/fonts').iterdir()):
        if not directory.is_dir():continue
        present={int(p.stem,16) for p in directory.glob('*.png')}
        absent=sorted(used-present);font_coverage[directory.name]={'glyphs':len(present),'missing':absent}
        errors.extend(f'{directory.name}: missing U+{code:04X}' for code in absent)
    graphics={}
    for source in sorted((ROOT/'src/caelum/ui').glob('*.zs')):
        for path in re.findall(r'"(graphics/[^"\n]+\.(?:png|jpg))"',source.read_text(encoding='utf-8-sig')):
            graphics.setdefault(path,[]).append(source.relative_to(ROOT).as_posix())
    errors.extend('Missing UI graphic '+path for path in graphics if not (ROOT/'src'/path).is_file())
    report={'issue':465,'baseline':baseline,'retained_font_files':retained,'font_coverage':font_coverage,
        'localization_keys':len(values),'missing_es_en':missing,'literal_ui_graphics':graphics,
        'notice_count':len(list((ROOT/'src/licenses').glob('*'))),'generated_outputs':{name:hashlib.sha256(blob).hexdigest() for name,blob in output.items()},
        'errors':errors,'limits':['Literal UI references do not exhaust dynamic inventory icon selection. Unchanged accepted inventory/model coverage remains supported by its original per-issue validators.','Native OptionMenu font selection is engine-owned; aliases alone do not prove replacement.','Author review and physical controller/wheel operation remain pending.']}
    destination=Path(__file__).with_name('evidence')/'static.json';destination.write_bytes((json.dumps(report,ensure_ascii=False,indent=2)+'\n').encode('utf8'))
    print(json.dumps({'retained_font_files':len(retained),'fonts':len(font_coverage),'keys':len(values),'literal_ui_graphics':len(graphics),'errors':errors}))
    raise SystemExit(bool(errors))


if __name__=='__main__':main()

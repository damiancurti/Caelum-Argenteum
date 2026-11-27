"""Inventory runtime provenance and unresolved independent-startup dependencies.

This reads recorded origins. Hash/path matches are traceability evidence, not
new license grants. It never includes a development IWAD or test fixture.
"""
from pathlib import Path
from collections import defaultdict,Counter
import argparse,fnmatch,hashlib,json,os,re,struct,zipfile

ROOT=Path(__file__).resolve().parents[2]


def digest(blob):return hashlib.sha256(blob).hexdigest()


def metadata_index(root):
    hashes=defaultdict(set);paths=defaultdict(set);documents=0
    for directory,children,files in os.walk(root/'assets'):
        children[:]=sorted(c for c in children if not c.startswith('validation') and c not in ['__pycache__','.git','distribution'])
        for name in sorted(files):
            if not name.endswith('.json'):continue
            path=Path(directory)/name
            try:data=json.loads(path.read_text(encoding='utf-8-sig'))
            except (UnicodeError,ValueError):continue
            documents+=1;reference=path.relative_to(root).as_posix()
            def walk(value):
                if isinstance(value,dict):
                    for key,item in value.items():walk(key);walk(item)
                elif isinstance(value,list):
                    for item in value:walk(item)
                elif isinstance(value,str):
                    if re.fullmatch('[0-9a-fA-F]{64}',value):hashes[value.lower()].add(reference)
                    if value.startswith(('src/','src\\')):paths[value.replace('\\','/')].add(reference)
            walk(data)
    return hashes,paths,documents


def map_textures(blob):
    if blob[:4] not in [b'PWAD',b'IWAD']:raise ValueError('Not a map WAD')
    _,count,offset=struct.unpack_from('<4sii',blob)
    names=set()
    for index in range(count):
        start,size,name=struct.unpack_from('<ii8s',blob,offset+16*index)
        if name.rstrip(b'\0')!=b'TEXTMAP':continue
        for match in re.finditer(rb'\btexture(?:top|bottom|middle|floor|ceiling)\s*=\s*"([^\"]+)"',blob[start:start+size],re.I):
            if match[1]!=b'-':names.add(match[1].decode('ascii').upper())
    return sorted(names)


def audit(root=ROOT):
    catalogue=json.loads((root/'assets/distribution/ORIGINS.json').read_text(encoding='utf8'))
    audio=json.loads((root/catalogue['audio_catalogue']).read_text(encoding='utf8'))
    audio={row['path']:row for row in audio['assets']}
    hashes,paths,documents=metadata_index(root);errors=[];rows=[];map_refs=defaultdict(list)
    map_catalogue=json.loads((root/'assets/map_catalogue/MAPS.json').read_text(encoding='utf8'))
    excluded_maps={'maps/'+entry['lump']+'.wad' for entry in map_catalogue['maps'].values() if entry['kind']=='test'}
    dependencies=json.loads((root/'assets/distribution/DEPENDENCIES.json').read_text(encoding='utf8'))
    for key,decision in catalogue['decisions'].items():
        for reference in decision['references']:
            if not (root/reference).is_file():errors.append(f'{key}: missing {reference}')
    for path in sorted((root/'src').rglob('*')):
        if not path.is_file():continue
        name=path.relative_to(root/'src').as_posix();blob=path.read_bytes();sha=digest(blob)
        matches=[r['decision'] for r in catalogue['rules'] if any(fnmatch.fnmatchcase(name,p) for p in r['patterns'])]
        if not matches:errors.append('No origin decision: '+name);continue
        decision=matches[0]
        refs=set()
        exact=sorted(hashes[sha]|paths['src/'+name]);refs.update(exact)
        if decision=='source-specific-audio':
            source=audio.get(name)
            if source is None or source['sha256']!=sha:errors.append('Audio differs from verified catalogue: '+name)
            elif source:
                for reference in source['credit_records']:
                    full=reference if reference.startswith('assets/') else 'src/'+reference
                    if not (root/full).is_file():errors.append('Missing audio credit: '+full)
                    refs.add(full)
        if name.startswith('maps/') and name.endswith('.wad'):
            for texture in map_textures(blob):map_refs[texture].append(name)
        forbidden=path.suffix.lower() in ['.exe','.dll','.zds','.ipk3','.pk3','.bat','.ps1'] or path.name.lower() in ['doom.wad','doom2.wad','id24res.wad']
        if forbidden:errors.append('Excluded runtime member: '+name)
        rows.append({'path':name,'sha256':sha,'bytes':len(blob),'decision':decision,
            'additional_provenance':sorted(refs),'exact_metadata':exact,
            'distribution':'exclude-development-map' if name in excluded_maps else 'retain-with-source-terms',
            'dependency_ids':[entry['id'] for entry in dependencies['findings'] if 'src/'+name in entry.get('affected_sources',[])]})
    sprites={p.stem[:4].upper() for p in (root/'src/sprites').rglob('*.png')}
    for path in [root/'src/TEXTURES',*sorted((root/'src').rglob('*.textures'))]:
        sprites.update(x[:4].upper() for x in re.findall(r'\bSprite\s+"?([\w]+)',path.read_text(encoding='utf-8-sig'),re.I))
    state_refs=defaultdict(set)
    for path in sorted((root/'src/caelum').rglob('*.zs')):
        for line in path.read_text(encoding='utf-8-sig').splitlines():
            match=re.match(r'\s*([A-Z0-9_#-]{4})\s+[A-Z#]+\s+-?\d+(?:\s|;)',line)
            if match and match[1] not in ['TNT1','####','----']:
                state_refs[match[1]].add(path.relative_to(root).as_posix())
    return {'schema':1,'issue':466,'runtime_files':len(rows),'metadata_documents':documents,
        'origin_decisions':'assets/distribution/ORIGINS.json',
        'dependency_findings':'assets/distribution/DEPENDENCIES.json',
        'provenance_resolution':'Union of the decision references and per-file additional_provenance; exact_metadata is traceability, not a license grant.',
        'hash_scope':'Actual source working-tree bytes used for this package snapshot. A checkout that changes text line endings requires regeneration; hashes are not Git blob identities.',
        'excluded_development_maps':sorted(excluded_maps),
        'origin_counts':dict(Counter(row['decision'] for row in rows)),
        'exact_metadata_files':sum(bool(row['exact_metadata']) for row in rows),
        'files':rows,'map_texture_references':dict(sorted(map_refs.items())),
        'explicit_sprite_prefixes':len(state_refs),
        'unresolved_explicit_sprites':{k:sorted(v) for k,v in sorted(state_refs.items()) if k not in sprites},
        'errors':errors,'limits':[
            'Recorded origins and author statements are preserved; hash/path matches are not independent legal clearance.',
            'Lexical sprite references do not include every inherited/default engine dependency. Native probes and class-default review are separate evidence.',
            'An inventory pass is not a claim that standalone startup is complete. #467 resolves the identified missing resources and excludes development maps.',
            'Existing author art tests, public-release source-quality qualifications and third-party terms remain applicable.']}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,default=ROOT/'assets/distribution/INVENTORY.json')
    parser.add_argument('--check',action='store_true')
    args=parser.parse_args();report=audit();blob=(json.dumps(report,ensure_ascii=False,indent=2)+'\n').encode('utf8')
    if args.check:
        if not args.output.exists() or args.output.read_bytes()!=blob:raise SystemExit('Stale distribution inventory')
    else:
        args.output.parent.mkdir(parents=True,exist_ok=True);args.output.write_bytes(blob)
    print(json.dumps({k:report[k] for k in ['runtime_files','metadata_documents','origin_counts','exact_metadata_files','unresolved_explicit_sprites','errors']}))
    raise SystemExit(bool(report['errors']))


if __name__=='__main__':main()

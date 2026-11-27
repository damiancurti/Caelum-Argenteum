"""Build a deterministic standalone IPK3 from an audited development package.

GZDoom and commercial IWADs are never copied. Input source bytes must match the
current inventory; the five authoritative development maps are filtered out.
"""
from pathlib import Path
import argparse,ast,contextlib,hashlib,json,re,sys,zipfile
from assets.generators.audit_distribution import audit
from assets.generators.generate_standalone_467 import generate

ROOT=Path(__file__).resolve().parent
STAMP=(1980,1,1,0,0,0)
SUPPORT_FILES=[
    'run_release.ps1','migrate_standalone_save.py','migrate_arena_save.py','LICENSE.md',
    'caelum_standalone.py','caelum_sessions.py','caelum_profiles.py',
    'caelum_profile_graph.py','caelum_campaigns.py','caelum_session_menu.py',
    'caelum_new_campaign.py','caelum_transfer_verify.py',
    'assets/profiles/verification.zs','assets/profiles/session-menu.json',
    'assets/profiles/personal-boundary.json']


def sha(blob):return hashlib.sha256(blob).hexdigest()


def check_support_imports():
    """Fail before packaging if a supplied helper imports an omitted local module."""
    supplied=set(SUPPORT_FILES)
    for name in SUPPORT_FILES:
        if not name.endswith('.py'):continue
        tree=ast.parse((ROOT/name).read_text(encoding='utf8'))
        for node in ast.walk(tree):
            modules=[item.name for item in node.names] if isinstance(node,ast.Import) else [node.module] if isinstance(node,ast.ImportFrom) and node.module else []
            for module in modules:
                local=module.split('.')[0]+'.py'
                if (ROOT/local).is_file() and local not in supplied:
                    raise ValueError(f'Missing release support dependency: {name} imports {local}')


def build(source,output,legacy_map02_revision5=False,legacy_map03_revision3=False):
    check_support_imports()
    source=source.resolve(strict=True) if source else None;output=output.resolve()
    if output==ROOT or output.is_relative_to(ROOT/'src') or output.is_relative_to(ROOT/'assets'):
        raise ValueError('Release output must be outside maintained source/assets')
    if output.exists():raise ValueError('Use a new output directory; existing artifacts are preserved')
    for name,blob in generate().items():
        if (ROOT/name).read_bytes()!=blob:raise ValueError('Stale standalone output: '+name)
    inventory=audit()
    if inventory['errors'] or inventory['unresolved_explicit_sprites']:
        raise ValueError('Resolve source inventory errors before packaging')
    rows={r['path']:r for r in inventory['files']}
    replacements={};variants=[]
    for enabled,map_name,folder,variant in [
        (legacy_map02_revision5,'MAP02','assets/map02_maze/legacy_5161','map02-r5'),
        (legacy_map03_revision3,'MAP03','assets/map06_port/legacy_5162','map03-r3')]:
        if not enabled:continue
        directory=ROOT/folder
        record=json.loads((directory/'PROVENANCE.json').read_text(encoding='utf8'))
        blob=(directory/(map_name+'.wad')).read_bytes()
        if sha(blob)!=record['files'][map_name+'.wad']['sha256']:raise ValueError('Legacy '+map_name+' source checksum mismatch')
        replacements['maps/'+map_name+'.wad']=blob
        row=rows['maps/'+map_name+'.wad'];row['sha256']=sha(blob);row['bytes']=len(blob)
        row['source_variant']=variant;variants.append(variant)
        row['additional_provenance']+=[folder+'/PROVENANCE.json']
    excluded=set(inventory['excluded_development_maps'])
    with zipfile.ZipFile(source) if source else contextlib.nullcontext() as archive:
        names=archive.namelist() if archive else list(rows)
        if len(names)!=len(set(names)) or set(names)!=set(rows):raise ValueError('Input members differ from audited source')
        if archive and archive.testzip() is not None:raise ValueError('Input package CRC failure')
        required={'IWADINFO','PLAYPAL','ZSCRIPT','MAPINFO','maps/MAP01.wad','maps/MAP02.wad','maps/MAP03.wad','licenses/STANDALONE_467.txt'}
        if not required.issubset(names):raise ValueError('Missing standalone bootstrap or prologue maps')
        output.mkdir(parents=True)
        target=output/'caelum_argenteum.ipk3'
        with zipfile.ZipFile(target,'x',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as release:
            for name in sorted(set(names)-excluded):
                blob=replacements.get(name)
                if blob is None:blob=archive.read(name) if archive else (ROOT/'src'/name).read_bytes()
                if sha(blob)!=rows[name]['sha256']:raise ValueError('Input differs from source: '+name)
                info=zipfile.ZipInfo(name,STAMP)
                # Recompressing already compressed media adds cost with little saving.
                info.compress_type=zipfile.ZIP_STORED if Path(name).suffix.lower() in ['.png','.ogg','.mp3','.jpg','.jpeg'] else zipfile.ZIP_DEFLATED
                info.create_system=0;info.external_attr=0x20
                release.writestr(info,blob,compresslevel=6)
    readme=(ROOT/'README.md').read_text(encoding='utf8')
    version=re.search(r'Current release:\s*([0-9]+\.[0-9]+\.[0-9]+[a-z]?)',readme)[1]
    guide=readme.split('<!-- independent-player-guide:start -->',1)[1].split('<!-- independent-player-guide:end -->',1)[0].strip()+'\n'
    manifest={'schema':1,'issue':469,'runtime_builder_origin_issue':467,'version':version,'engine':'GZDoom 4.14.2 installed separately','commercial_iwad_required':False,
        'variant':'legacy-'+'-'.join(variants) if variants else 'current',
        'game':'caelum_argenteum.ipk3','sha256':sha(target.read_bytes()),'bytes':target.stat().st_size,
        'source_package_sha256':sha(source.read_bytes()) if source else None,
        'source_tree_sha256':sha(''.join(name+'\0'+rows[name]['sha256']+'\n' for name in sorted(rows)).encode()),
        'excluded_development_maps':sorted(excluded),
        'files':[rows[name] for name in sorted(set(rows)-excluded)],
        'origins':'ORIGINS.json','limits':'Review beta: author acceptance, earlier pending checks and documented mode/campaign limitations remain applicable.'}
    (output/'MANIFEST.json').write_bytes((json.dumps(manifest,ensure_ascii=False,indent=2)+'\n').encode('utf8'))
    (output/'ORIGINS.json').write_bytes((ROOT/'assets/distribution/ORIGINS.json').read_bytes())
    for name in SUPPORT_FILES:
        target_file=output/name;target_file.parent.mkdir(parents=True,exist_ok=True)
        target_file.write_bytes((ROOT/name).read_bytes())
    (output/'PLAYER_GUIDE.txt').write_bytes(guide.encode('utf8'))
    members=sorted(p for p in output.rglob('*') if p.is_file())
    delivery=dict(schema=1,issue=469,version=version,variant=manifest['variant'],
        engine_bundled=False,commercial_iwad_required=False,advanced_tools='Python 3.12 standard library; optional for solo play',
        files=[dict(path=p.relative_to(output).as_posix(),sha256=sha(p.read_bytes()),bytes=p.stat().st_size) for p in members])
    (output/'DELIVERY.json').write_bytes((json.dumps(delivery,indent=2)+'\n').encode('utf8'))
    members=sorted(p for p in output.rglob('*') if p.is_file())
    (output/'SHA256SUMS.txt').write_bytes(''.join(sha(p.read_bytes())+'  '+p.relative_to(output).as_posix()+'\n' for p in members).encode('utf8'))
    print(json.dumps({'package':str(target),'files':len(manifest['files']),'excluded_test_maps':len(excluded),'sha256':manifest['sha256']}))
    return manifest


def archive_release(directory):
    """Export exactly the verified directory with fixed archive metadata."""
    target=directory.parent/(directory.name+'.zip')
    checksum=target.with_suffix('.zip.sha256')
    if target.exists() or checksum.exists():raise ValueError('Release archive already exists; select a new directory name')
    with zipfile.ZipFile(target,'x',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as archive:
        for path in sorted(p for p in directory.rglob('*') if p.is_file()):
            info=zipfile.ZipInfo(path.relative_to(directory).as_posix(),STAMP)
            info.compress_type=zipfile.ZIP_STORED if path.suffix=='.ipk3' else zipfile.ZIP_DEFLATED
            info.create_system=0;info.external_attr=0x20
            archive.writestr(info,path.read_bytes(),compresslevel=6)
    checksum.write_text(sha(target.read_bytes())+'  '+target.name+'\n',encoding='ascii',newline='\n')
    print(json.dumps(dict(archive=str(target),sha256=sha(target.read_bytes()),bytes=target.stat().st_size)))


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--input',type=Path,help='Optional development package from this exact tree; otherwise read src directly')
    parser.add_argument('--output',type=Path,required=True,help='New release directory; existing files are never removed')
    parser.add_argument('--zip',action='store_true',help='Also write a deterministic sibling ZIP and external SHA-256 file')
    parser.add_argument('--legacy-map02-revision5',action='store_true',help='Retain the verified pre-redesign MAP02 geometry for existing visited-map saves')
    parser.add_argument('--legacy-map03-revision3',action='store_true',help='Retain the verified pre-redesign MAP03 geometry for existing visited-city saves; may combine with MAP02 compatibility')
    args=parser.parse_args();build(args.input,args.output,args.legacy_map02_revision5,args.legacy_map03_revision3)
    if args.zip:archive_release(args.output.resolve())


if __name__=='__main__':main()

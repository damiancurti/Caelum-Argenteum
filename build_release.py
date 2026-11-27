"""Build a deterministic standalone IPK3 from an audited development package.

GZDoom and commercial IWADs are never copied. Input source bytes must match the
current inventory; the five authoritative development maps are filtered out.
"""
from pathlib import Path
import argparse,contextlib,hashlib,json,sys,zipfile
from assets.generators.audit_distribution import audit
from assets.generators.generate_standalone_467 import generate

ROOT=Path(__file__).resolve().parent
STAMP=(1980,1,1,0,0,0)


def sha(blob):return hashlib.sha256(blob).hexdigest()


def build(source,output,legacy_map02_revision5=False,legacy_map03_revision3=False):
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
    manifest={'schema':1,'issue':467,'engine':'GZDoom 4.14.2 installed separately','commercial_iwad_required':False,
        'variant':'legacy-'+'-'.join(variants) if variants else 'current',
        'game':'caelum_argenteum.ipk3','sha256':sha(target.read_bytes()),'bytes':target.stat().st_size,
        'source_package_sha256':sha(source.read_bytes()) if source else None,
        'source_tree_sha256':sha(''.join(name+'\0'+rows[name]['sha256']+'\n' for name in sorted(rows)).encode()),
        'excluded_development_maps':sorted(excluded),
        'files':[rows[name] for name in sorted(set(rows)-excluded)],
        'origins':'ORIGINS.json','limits':'Review beta: author acceptance, earlier pending checks and documented mode/campaign limitations remain applicable.'}
    (output/'MANIFEST.json').write_bytes((json.dumps(manifest,ensure_ascii=False,indent=2)+'\n').encode('utf8'))
    (output/'ORIGINS.json').write_bytes((ROOT/'assets/distribution/ORIGINS.json').read_bytes())
    for name in ['run_release.ps1','migrate_standalone_save.py']:
        (output/name).write_bytes((ROOT/name).read_bytes())
    print(json.dumps({'package':str(target),'files':len(manifest['files']),'excluded_test_maps':len(excluded),'sha256':manifest['sha256']}))
    return manifest


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--input',type=Path,help='Optional development package from this exact tree; otherwise read src directly')
    parser.add_argument('--output',type=Path,required=True,help='New release directory; existing files are never removed')
    parser.add_argument('--legacy-map02-revision5',action='store_true',help='Retain the verified pre-redesign MAP02 geometry for existing visited-map saves')
    parser.add_argument('--legacy-map03-revision3',action='store_true',help='Retain the verified pre-redesign MAP03 geometry for existing visited-city saves; may combine with MAP02 compatibility')
    args=parser.parse_args();build(args.input,args.output,args.legacy_map02_revision5,args.legacy_map03_revision3)


if __name__=='__main__':main()

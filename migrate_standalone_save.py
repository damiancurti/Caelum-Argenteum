"""Copy a native save between development and standalone package identities.

Both packages must contain byte-identical versions of every stored map. This
does not bypass native map checksum validation or reinterpret another layout.
The original save/package remain the rollback path. Existing outputs are never
overwritten. For older #460 motion rollback, use its separate documented tool.
"""
from pathlib import Path
import argparse,hashlib,json,zipfile

REVISION=1


def sha(blob):return hashlib.sha256(blob).hexdigest()


def migrate(source,destination,source_package,target_package,target_iwad=None):
    source=source.resolve(strict=True);destination=destination.resolve()
    source_package=source_package.resolve(strict=True);target_package=target_package.resolve(strict=True)
    receipt=destination.with_suffix('.migration.json')
    if destination.exists() or receipt.exists():raise ValueError('Choose a new destination; original saves and receipts are preserved')
    if target_iwad is None:target_iwad=target_package.name
    if Path(target_iwad).name!=target_iwad or ':' in target_iwad:raise ValueError('Target IWAD must be a leaf filename')
    original=source.read_bytes();entries=[];changed=0;voice_repairs=0;maps=[]
    with zipfile.ZipFile(source) as saved,zipfile.ZipFile(source_package) as before,zipfile.ZipFile(target_package) as after:
        info=json.loads(saved.read('info.json'))
        if info.get('Engine')!='GZDOOM' or info.get('Save Version')!=4560:raise ValueError('Only GZDoom 4.14.2 save format 4560 is supported')
        if info.get('Map WAD','').lower()!=source_package.name.lower():raise ValueError('Source package filename does not match the saved map owner')
        saved_maps=[n for n in saved.namelist() if n.endswith('.map.json')]
        if not saved_maps:raise ValueError('No native stored maps found')
        before_names={n.lower():n for n in before.namelist()};after_names={n.lower():n for n in after.namelist()}
        for name in saved_maps:
            member='maps/'+name.removesuffix('.map.json')+'.wad'
            if member not in before_names or member not in after_names:raise ValueError('Stored map not present in both packages: '+member)
            old=before.read(before_names[member]);new=after.read(after_names[member])
            if old!=new:raise ValueError('Map layout differs: '+member+'. Select the matching compatibility package; keep the original save.')
            maps.append({'map':member,'sha256':sha(old)})
        prior={'Game WAD':info['Game WAD'],'Map WAD':info['Map WAD']}
        for key,value in [('Game WAD',target_iwad),('Map WAD',target_package.name)]:
            if info[key]!=value:info[key]=value;changed+=1
        to_development=target_iwad.lower() in ['doom.wad','doom2.wad']
        for entry in saved.infolist():
            blob=saved.read(entry.filename)
            if entry.filename=='info.json' and changed:
                blob=json.dumps(info,ensure_ascii=False,separators=(',',':')).encode('utf8')
            if to_development and entry.filename.endswith('.map.json'):
                data=json.loads(blob);local=0
                for obj in data.get('objects',[]):
                    fields=obj.get('class:PlayerPawn',{})
                    if fields.get('SoundClass') in ['caelum_male','caelum_female']:
                        fields['SoundClass']='player';local+=1
                if local:blob=json.dumps(data,ensure_ascii=False,separators=(',',':')).encode('utf8');voice_repairs+=local
            entries.append((entry,blob))
    destination.parent.mkdir(parents=True,exist_ok=True)
    if not changed and not voice_repairs:
        with destination.open('xb') as stream:stream.write(original)
    else:
        with zipfile.ZipFile(destination,'x') as converted:
            for entry,blob in entries:converted.writestr(entry,blob)
    assert source.read_bytes()==original
    report={'issue':467,'migration_revision':REVISION,'source':str(source),'source_sha256':sha(original),
        'destination_sha256':sha(destination.read_bytes()),'source_package_sha256':sha(source_package.read_bytes()),
        'target_package_sha256':sha(target_package.read_bytes()),'original_metadata':prior,
        'target_metadata':{'Game WAD':target_iwad,'Map WAD':target_package.name},'metadata_fields_changed':changed,
        'native_voice_fields_restored':voice_repairs,'identical_maps':maps,'original_preserved':True,
        'native_load_required':True,'rollback':'Use the preserved original save with its exact original package, or convert a new save back with matching source/target maps and --target-iwad DOOM2.WAD. Earlier motion rollback remains a separate #460 step.'}
    with receipt.open('x',encoding='utf8',newline='\n') as stream:json.dump(report,stream,ensure_ascii=False,indent=2);stream.write('\n')
    return report


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source',type=Path);parser.add_argument('destination',type=Path)
    parser.add_argument('--source-package',type=Path,required=True)
    parser.add_argument('--target-package',type=Path,required=True)
    parser.add_argument('--target-iwad',help='Only for a deliberate development rollback; e.g. DOOM2.WAD. No IWAD is copied.')
    args=parser.parse_args();print(json.dumps(migrate(args.source,args.destination,args.source_package,args.target_package,args.target_iwad),ensure_ascii=False))


if __name__=='__main__':main()

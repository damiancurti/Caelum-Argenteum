"""Read-only integrity checks for the fitted wardrobe and native pose bindings."""
from pathlib import Path
import hashlib,json,math,struct
try:
    from .validate_underbody import validate_binding
except ImportError:
    from validate_underbody import validate_binding
ROOT=Path(__file__).resolve().parents[2]


def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def validate(root=ROOT):
    errors=[]
    try:
        art=root/'assets/source/art/worn_clothing_829'
        cfg=json.loads((art/'DESIGN.json').read_text());report=json.loads((art/'EXPORT.json').read_text())
        if report.get('preview_only'):errors.append('A provisional mixed wardrobe export cannot be installed')
        author=json.loads((art/'AUTHORING.json').read_text())
        visibility=json.loads((art/'VISIBILITY.json').read_text())
        slots=visibility['fixture_slots']
        if len(slots)!=15 or len(set(slots))!=15 or set(visibility['body_items_hidden'])!={row[0] for row in cfg['combinations']}:
            errors.append('Worn clothing incomplete visibility catalogue')
        selections=[visibility['body_absent_hidden'],*visibility['body_items_hidden'].values()]
        selections.extend(names for rule in visibility['other_regions'].values() for names in rule.values())
        if any(len(names)!=len(set(names)) or set(names)-set(slots) for names in selections):errors.append('Worn clothing invalid visibility module')
        pairs=[(art/'wardrobe.blend',report['source_sha256']),(art/'wardrobe.blend',author['editable_sha256']),
               (art/'DESIGN.json',report['config_sha256']),(art/'DESIGN.json',author['config_sha256']),
               (root/'assets/generators/export_worn_clothing.py',report['generator_sha256']),
               (root/'assets/generators/author_worn_clothing.py',author['authoring_sha256']),
               (root/cfg['anatomy_source'],cfg['anatomy_sha256']),
               (root/'src/models/caelum/characters/domingo/underbody.md3',report['body_source_sha256'])]
        pairs.extend((root/name,expected) for name,expected in cfg['source_sha256'].items())
        pairs.extend((root/row['source'],row['sha256']) for row in author['packed_images'].values())
        for path,expected in pairs:
            if digest(path)!=expected:errors.append('Worn clothing stale input '+str(path.relative_to(root)))
        expected={key for combo in cfg['combinations'] for key in combo if key}
        skin={'base_core','base_arms','base_forearms','base_neck','base_feet','hair_lower'}
        hems={'pants_'+row[0]+'_'+variant for row in cfg['combinations'] for variant in cfg['trouser_hems']['variants']}
        if len(expected)!=25 or set(report['modules'])!=expected|skin|hems:errors.append('Worn clothing incomplete 25-item catalogue, body masks or footwear-dependent hems')
        if report['frames']!=375 or report['actions']!=24:errors.append('Worn clothing incomplete action samples')
        for name,expected_hash in report['sha256'].items():
            path=art/'worn_preview.modeldef' if name=='MODELDEF' else root/'src'/name
            if digest(path)!=expected_hash:errors.append('Worn clothing stale export '+name)
        for key,counts in report['modules'].items():
            rows=author['modules'][key]
            if key.startswith('pants_'):
                body=key.split('_')[1]
                if counts['texture']!=report['modules'][body]['texture'] or sum('tailored trousers' in r['object'] for r in rows)!=1:
                    errors.append('Worn clothing hem loses its garment material or connected trousers '+key)
            if len(rows)!=counts['parts'] or any(r['nonmanifold_edges'] or r['rest_signed_volume']<=0 for r in rows):
                errors.append('Worn clothing open or inverted source '+key)
            if any(r['max_weight_sum_error']>=1e-5 or ('tailored trousers' in r['object'] and r['connected_components']!=1) for r in rows):
                errors.append('Worn clothing disconnected trousers or invalid weights '+key)
            if any(r['deformation_role'] in ['torso','draped_torso'] and set(r['weight_groups'])-set(cfg['torso_weights']['allowed_bones']) for r in rows):
                errors.append('Worn clothing torso follows unrelated limb bones '+key)
            blob=(root/'src'/cfg['native_model_path']/(key+'.md3')).read_bytes()
            header=struct.unpack_from('<4sI64s9I',blob);offset=header[10];surface=struct.unpack_from('<4s64s10I',blob,offset)
            if header[:2]!=(b'IDP3',15) or header[6]!=1 or header[11]!=len(blob) or offset+surface[11]!=len(blob):
                errors.append('Worn clothing invalid native container '+key)
            if (header[4],surface[3],surface[5],surface[6])!=(375,375,counts['vertices'],counts['triangles']):
                errors.append('Worn clothing native counts differ '+key)
            shader=blob[offset+surface[8]:offset+surface[8]+64].split(b'\0')[0].decode()
            if shader!=counts['texture'] or not (root/'src'/shader).is_file():errors.append('Worn clothing unresolved texture '+key)
            for index in range(surface[6]):
                triangle=struct.unpack_from('<3I',blob,offset+surface[7]+index*12)
                if max(triangle)>=surface[5] or len(set(triangle))!=3:errors.append('Worn clothing invalid triangle '+key);break
            uv=struct.unpack_from('<'+str(surface[5]*2)+'f',blob,offset+surface[9])
            if not all(math.isfinite(v) and -1e-5<=v<=1.00001 for v in uv):errors.append('Worn clothing invalid texture coordinates '+key)
            if surface[10]+surface[5]*375*8!=surface[11]:errors.append('Worn clothing incomplete vertex samples '+key)
        errors.extend('Worn clothing '+e for e in validate_binding((art/'worn_preview.modeldef').read_text(),slots=15))
        if not (root/'src/licenses/WORN_CLOTHING_829.txt').is_file():errors.append('Missing fitted clothing attribution')
    except (OSError,KeyError,ValueError,struct.error) as exc:errors.append('Worn clothing: '+str(exc))
    return errors


if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))

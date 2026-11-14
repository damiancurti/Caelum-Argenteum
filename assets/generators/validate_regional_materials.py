"""Validate installed regional textures and the approved gallery source associations."""
from pathlib import Path
import hashlib
import json
from PIL import Image

ROOT=Path(__file__).resolve().parents[2]


def validate(root=ROOT, issue=463):
    errors=[]
    try:
        source=root/'assets/source/art'/f'regional_gallery_{issue}'
        config=json.loads((source/'INVENTORY.json').read_text())
        report=json.loads((source/'EXPORT.json').read_text())
        provenance=json.loads((source/'PROVENANCE.json').read_text())
        gallery=json.loads((source/'GALLERY.json').read_text())
        sources={source/name:checksum for name,checksum in report['source_sha256'].items()}
        sources.update({root/name:checksum for name,checksum in config['source_sha256'].items()})
        sources[root/'assets/generators/generate_regional_materials.py']=report['generator_sha256']
        for path,want in sources.items():
            if hashlib.sha256(path.read_bytes()).hexdigest()!=want:errors.append('Stale source: '+str(path.relative_to(root)))
        for name,want in report['sha256'].items():
            if hashlib.sha256((root/'src'/name).read_bytes()).hexdigest()!=want:errors.append('Stale installed material: '+name)
        for item in config['gaps']:
            path=source/item['image']
            if hashlib.sha256(path.read_bytes()).hexdigest()!=item['sha256'] or provenance['images'][item['key']]['sha256']!=item['sha256']:
                errors.append('Original-image hash mismatch: '+item['key'])
            if hashlib.sha256((source/item['prompt']).read_bytes()).hexdigest()!=provenance['images'][item['key']]['prompt_sha256']:
                errors.append('Original-prompt hash mismatch: '+item['key'])
            with Image.open(path) as image:
                if list(image.size)!=item['image_size'] or image.convert('RGBA').getchannel('A').getextrema()!=(255,255):
                    errors.append('Invalid opaque material image: '+item['key'])
        include='#include "'+config.get('definition','caelum/data/regional_materials.textures')+'"'
        if (root/'src/TEXTURES').read_text(encoding='utf-8').count(include)!=1:errors.append('Expected one native material include')
        regions=json.loads((root/'assets/bestiary/REGION_PROPOSAL.json').read_text())
        assignments={row['id']:row['proposed_campaign_regions'] for row in regions['entries']}
        if gallery['map']!=f'CA{issue}G' or gallery['status']!='isolated_visual_inspection_not_campaign':errors.append('Gallery must remain isolated')
        for item in gallery['subjects']:
            if item['region'] not in assignments[item['catalogue_id']]:errors.append('Unapproved gallery region for '+item['catalogue_id'])
        material_names={item['texture'] for item in config['gaps']} | set(config.get('reused_materials',[]))
        if {plot['floor'] for plot in gallery['plots']}!=material_names:errors.append('Gallery material coverage differs')
    except (OSError,KeyError,ValueError) as exc:errors.append(str(exc))
    return ['Regional materials: '+error for error in errors]


if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))

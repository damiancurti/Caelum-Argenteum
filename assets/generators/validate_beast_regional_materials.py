"""Validate the new regional studies and their approved creature associations."""
from pathlib import Path
import json
try:
    from .validate_regional_materials import validate as shared_validate
except ImportError:
    from validate_regional_materials import validate as shared_validate
ROOT=Path(__file__).resolve().parents[2]
def validate(root=ROOT):
    errors=shared_validate(root,issue=682)
    try:
        gallery=json.loads((root/'assets/source/art/regional_gallery_682/GALLERY.json').read_text())
        models=json.loads((root/'assets/source/art/beast_men_680/ANIMATION.json').read_text())['species']
        actors={item['catalogue_id']:item['actor'] for item in models.values()}
        regions=json.loads((root/'assets/bestiary/REGION_PROPOSAL.json').read_text())['entries']
        expected={(row['id'],region) for row in regions if row['id'] in actors for region in row['proposed_campaign_regions']}
        actual=[(row['catalogue_id'],row['region']) for row in gallery['subjects']]
        assert len(actual)==len(set(actual)) and set(actual)==expected,'Missing or duplicate approved display'
        plots={row['region']:row for row in gallery['plots']}
        assert len(plots)==len(gallery['plots'])
        for row in gallery['subjects']:
            assert row['class']==actors[row['catalogue_id']],'Incorrect native species class'
            x,y,z=row['position'];left,right=plots[row['region']]['x']
            assert left<x<right and gallery['plot_y'][0]<y<gallery['plot_y'][1] and z==0,'Display outside its regional floor'
        for left,right in zip(gallery['plots'],gallery['plots'][1:]):
            assert left['x'][1]==right['x'][0],'Noncontiguous plot boundary'
        assert gallery['walkway_y'][1]==gallery['plot_y'][0],'Walkway is disconnected'
        assert sum(bool(row.get('control')) for row in gallery['views'])==1,'Expected one player-control view'
    except (OSError,KeyError,ValueError,AssertionError) as exc:
        errors.append('Beast regional gallery: '+(str(exc) or 'Invalid display layout'))
    return errors
if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))

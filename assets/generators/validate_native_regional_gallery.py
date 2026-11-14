"""Check the isolated native gallery's actual exports and approved associations."""
from pathlib import Path
import hashlib,json,math,re

ROOT=Path(__file__).resolve().parents[2]


def validate(root=ROOT):
    errors=[]
    try:
        source=root/'assets/source/art/regional_gallery_709'
        gallery=json.loads((source/'GALLERY.json').read_text())
        provenance=json.loads((source/'PROVENANCE.json').read_text())
        for name,want in provenance['reused_source_sha256'].items():
            assert hashlib.sha256((root/name).read_bytes()).hexdigest()==want,'Changed reused source: '+name
        assert gallery['map']=='CA709G' and gallery['status']=='isolated_visual_inspection_not_campaign'
        assert gallery['model_exports']==list(dict.fromkeys(b['export'] for b in gallery['model_bindings']))
        actors={};radii={};exports=[]
        for binding in gallery['model_bindings']:
            report=json.loads((root/binding['export']).read_text())
            profile=report['species'][binding['kind']]['native_profile'] if 'species' in report else report['inherited_defaults']
            radii[binding['actor']]=profile['Radius'];actors[binding['catalogue_id']]=binding['actor']
            assert binding['actor']=='CaelumBestiary'+binding['catalogue_id'].rsplit('-',1)[1]
            definitions=[];native=[]
            for name,want in report['sha256'].items():
                if not name.startswith(('models/','caelum/')):continue
                path=root/'src'/name
                assert hashlib.sha256(path.read_bytes()).hexdigest()==want,'Stale native source: '+name
                native.append(name)
                if name.endswith('.modeldef'):
                    definitions.append(path.read_text())
                    assert (root/'src/MODELDEF').read_text().count('#include "'+name+'"')==1
            assert any(re.search(r'\bModel\s+'+binding['actor']+r'\s*\{',text) for text in definitions),'Missing exact actor model binding'
            assert any(n.endswith('.md3') for n in native),'Missing native mesh'
            exports.extend(native)
        assignments=json.loads((root/'assets/bestiary/REGION_PROPOSAL.json').read_text())['entries']
        expected={(r['id'],region) for r in assignments if r['id'] in actors for region in r['proposed_campaign_regions']}
        actual=[(r['catalogue_id'],r['region']) for r in gallery['subjects']]
        assert len(actual)==len(set(actual)) and set(actual)==expected,'Missing/duplicate approved regional display'
        plots={p['region']:p for p in gallery['plots']}
        assert len(plots)==len(gallery['plots'])
        material=json.loads((root/'assets/source/art/regional_gallery_463/EXPORT.json').read_text())
        for name,want in material['sha256'].items():
            assert hashlib.sha256((root/'src'/name).read_bytes()).hexdigest()==want,'Changed regional material: '+name
        original=json.loads((root/'assets/source/art/regional_gallery_463/GALLERY.json').read_text())
        assert gallery['plots'][1:]==original['plots'],'Existing regional plots changed'
        assert gallery['plots'][0]==dict(region='Northwest Argentina',x=[-1536,-1024],floor='CRNOAGR'),'Unexpected NOA inspection plot'
        extra=json.loads((root/'assets/source/art/regional_gallery_682/EXPORT.json').read_text())
        for name,want in extra['sha256'].items():
            assert hashlib.sha256((root/'src'/name).read_bytes()).hexdigest()==want,'Changed NOA material: '+name
        for s in gallery['subjects']:
            assert s['class']==actors[s['catalogue_id']]
            x,y,z=s['position'];left,right=plots[s['region']]['x'];radius=radii[s['class']]
            assert left+radius<x<right-radius and gallery['plot_y'][0]+radius<y<gallery['plot_y'][1]-radius and z==0
        for i,a in enumerate(gallery['subjects']):
            for b in gallery['subjects'][i+1:]:
                assert math.dist(a['position'][:2],b['position'][:2])>radii[a['class']]+radii[b['class']],'Overlapping native bodies'
        for a,b in zip(gallery['plots'],gallery['plots'][1:]):assert a['x'][1]==b['x'][0]
        assert gallery['walkway_y'][1]==gallery['plot_y'][0]
        keys=[v['key'] for v in gallery['views']]
        assert len(keys)==len(set(keys)) and all(re.fullmatch(r'(?:F(?:[1-9]|1[0-2])|[0-9])',k) for k in keys)
        for view in gallery['views']:
            if view.get('control'):continue
            x,y,z=view['position']
            assert gallery['plots'][0]['x'][0]<x<gallery['plots'][-1]['x'][1] and gallery['walkway_y'][0]<y<gallery['plot_y'][1] and 0<z<gallery['ceiling_height'],'Camera outside inspection room'
        assert sum(bool(v.get('control')) for v in gallery['views'])==1
        assert gallery['silent_observer_steps'] and gallery['animation_sample_wait_tics']==11
    except (OSError,ValueError,KeyError,AssertionError) as exc:
        errors.append('Native regional gallery: '+(str(exc) or 'Invalid gallery configuration'))
    return errors


if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))

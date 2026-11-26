"""Check complete approved display coverage and the isolated third gallery."""
from pathlib import Path
from collections import Counter
import hashlib,json,math,re
ROOT=Path(__file__).resolve().parents[2]


def validate(root=ROOT):
    errors=[]
    try:
        source=root/'assets/source/art/regional_gallery_825'
        g=json.loads((source/'GALLERY.json').read_text(encoding='utf-8'))
        provenance=json.loads((source/'PROVENANCE.json').read_text(encoding='utf-8'))
        for name,want in provenance['reused_source_sha256'].items():
            assert hashlib.sha256((root/name).read_bytes()).hexdigest()==want,'Changed reused source: '+name
        assert g['issue']==825 and g['map']=='CA825G' and g['status']=='isolated_visual_inspection_not_campaign'
        assert len(g['subjects'])==44 and len(g['views'])==55 and len(g['plots'])==9
        assert g['model_exports']==list(dict.fromkeys(b['export'] for b in g['model_bindings']))
        actors={};radii={};checked=set()
        for b in g['model_bindings']:
            report=json.loads((root/b['export']).read_text());item=report['species'][b['kind']]
            assert item['catalogue_id']==b['catalogue_id'] and item['actor']==b['actor']
            assert b['actor']=='CaelumBestiary'+b['catalogue_id'].rsplit('-',1)[1]
            assert b['catalogue_id'] not in actors,'Duplicate model identity'
            actors[b['catalogue_id']]=b['actor']
            profile=item['native_profile'];factor=profile['Scale']*item['modeldef_scale']
            offset=item.get('authored_model_offset',[0,0,0])
            radii[b['actor']]=max(profile['Radius'],item['maximum_authored_radius']*factor+math.hypot(*offset[:2])*factor)
            definitions=[]
            for name,want in report['sha256'].items():
                if not name.startswith(('models/','caelum/')):continue
                p=root/'src'/name
                if name not in checked:
                    assert hashlib.sha256(p.read_bytes()).hexdigest()==want,'Stale native source: '+name
                    checked.add(name)
                if name.endswith('.modeldef'):
                    definitions.append(p.read_text())
                    assert (root/'src/MODELDEF').read_text().count('#include "'+name+'"')==1
            assert any(re.search(r'\bModel\s+'+b['actor']+r'\s*\{',t) for t in definitions),'Missing exact actor binding'
        assert len(actors)==30
        table=json.loads((root/'assets/bestiary/REGION_PROPOSAL.json').read_text())
        assert table['status']=='author_approved_2026_11_12'
        expected={(r['id'],region) for r in table['entries'] if r['id'] not in ['CA-FOLK-018','CA-FOLK-019'] for region in r['proposed_campaign_regions']}
        earlier=[s for n in [682,709] for s in json.loads((root/f'assets/source/art/regional_gallery_{n}/GALLERY.json').read_text())['subjects']]
        counts=Counter((s['catalogue_id'],s['region']) for s in [*earlier,*g['subjects']])
        assert set(counts)==expected and all(n==1 for n in counts.values()),'Missing/duplicate approved association across the three galleries'
        assert len(expected)==78 and len({a for a,b in expected})==56
        plots={p['region']:p for p in g['plots']};assert len(plots)==len(g['plots'])
        neutral={'Buenos Aires','Chaco','Supernatural domains'}
        for name,p in plots.items():
            assert p['x'][0]<p['x'][1]
            assert p['floor_status']==('neutral_inspection_floor_not_biome_art' if name in neutral else 'existing_owned_regional_study')
            if name in neutral:assert p['floor']==g['walkway_flat']=='CMST01'
        for s in g['subjects']:
            assert s['class']==actors[s['catalogue_id']]
            x,y,z=s['position'];left,right=plots[s['region']]['x'];radius=radii[s['class']]
            assert left+radius<x<right-radius and g['plot_y'][0]+radius<y<g['plot_y'][1]-radius and z==0,'Body/silhouette outside its diagnostic plot'
        for i,a in enumerate(g['subjects']):
            for b in g['subjects'][i+1:]:
                assert math.dist(a['position'][:2],b['position'][:2])>radii[a['class']]+radii[b['class']],'Overlapping full-animation silhouettes'
        for a,b in zip(g['plots'],g['plots'][1:]):assert a['x'][1]==b['x'][0]
        assert g['walkway_y'][1]==g['plot_y'][0]
        keys=[v['key'].lower() for v in g['views']]
        assert len(keys)==len(set(keys)) and not set(keys)&set('wasd'),'Duplicate keys or overwritten walking controls'
        assert all(re.fullmatch(r'(?:f(?:[1-9]|1[0-2])|[a-z0-9\[\]\-=/]|home|end|pgup|pgdn|ins|del)',k) for k in keys)
        for v in g['views']:
            if v.get('control'):continue
            x,y,z=v['position']
            assert g['plots'][0]['x'][0]<x<g['plots'][-1]['x'][1] and g['walkway_y'][0]<y<g['plot_y'][1] and 0<z<g['ceiling_height'],'Camera outside inspection room'
        subject_views=[v for v in g['views'] if 'catalogue_id' in v]
        assert {(v['catalogue_id'],v['region']) for v in subject_views}=={(s['catalogue_id'],s['region']) for s in g['subjects']}
        assert sum(bool(v.get('control')) for v in g['views'])==1
        assert g['silent_observer_steps'] and g['animation_sample_wait_tics']==11
    except (OSError,ValueError,KeyError,AssertionError) as exc:
        errors.append('Complete regional gallery: '+(str(exc) or 'Invalid gallery configuration'))
    return errors


if __name__=='__main__':
    errors=validate();print(json.dumps(dict(errors=errors)));raise SystemExit(bool(errors))

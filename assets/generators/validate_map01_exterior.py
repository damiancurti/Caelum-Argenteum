"""Read-only invariants for the #61 terrain, scenery and complete tympanum fill."""
from collections import Counter
import hashlib
import json
import math
from pathlib import Path
from repair_map01_mansion import read_map

ROOT=Path(__file__).resolve().parents[2]
DATA=ROOT/'assets/map01_mansion'


def main():
    spec=json.loads((DATA/'EXTERIOR.json').read_text(encoding='utf-8'))
    report=json.loads((DATA/'EXTERIOR_GENERATED.json').read_text(encoding='utf-8'))
    baseline=read_map(DATA/spec['baseline']);obj=read_map(ROOT/'src/maps/MAP01.wad')
    checks={}
    checks['preserved baseline hash']=hashlib.sha256((DATA/spec['baseline']).read_bytes()).hexdigest()==spec['baseline_sha256']
    checks['current map hash']=hashlib.sha256((ROOT/'src/maps/MAP01.wad').read_bytes()).hexdigest()==report['output_sha256']
    for kind in baseline:
        exceptions=set(spec['exterior_partition']['horizon_lines']) if kind in ('linedef','sidedef') else set()
        checks[f'original {kind} records unchanged outside declared horizon repair']=all(
            obj[kind][i]==item for i,item in enumerate(baseline[kind]) if i not in exceptions)
    checks['horizon changes only endpoints and front-sector references']=all(
        {k:val for k,val in obj['linedef'][i].items() if k!='v2'}=={k:val for k,val in baseline['linedef'][i].items() if k!='v2'}
        and {k:val for k,val in obj['sidedef'][i].items() if k!='sector'}=={k:val for k,val in baseline['sidedef'][i].items() if k!='sector'}
        for i in spec['exterior_partition']['horizon_lines'])
    v,lines,sides,sectors=(obj[k] for k in ('vertex','linedef','sidedef','sector'))
    checks['all references valid']=all(0<=line[k]<len(v) for line in lines for k in ('v1','v2')) and all(0<=line[k]<len(sides) for line in lines for k in ('sidefront','sideback') if line.get(k,-1)>=0) and all(0<=s['sector']<len(sectors) for s in sides)
    checks['no zero length lines']=all(v[l['v1']]!=v[l['v2']] for l in lines)
    newlines=lines[len(baseline['linedef']):report['terrain_linedef_end']]
    checks['all terrain edges traversable two-sided']=all(l.get('twosided') and l.get('sideback',-1)>=0 and not any(l.get(k) for k in ('blocking','blockplayers','blockmonsters','special')) for l in newlines)
    checks['no duplicate terrain edges']=max(Counter(tuple(sorted((l['v1'],l['v2']))) for l in newlines).values())==1
    def z(si,p):
        s=sectors[si]
        return -(s.get('floorplane_a',0)*p['x']+s.get('floorplane_b',0)*p['y']+s.get('floorplane_d',-s['heightfloor']))/s.get('floorplane_c',1)
    max_jump=max(abs(z(sides[l['sidefront']]['sector'],v[l[k]])-z(sides[l['sideback']]['sector'],v[l[k]])) for l in newlines for k in ('v1','v2'))
    checks['every shared terrain edge is continuous']=max_jump<0.00001
    heights=[z(t['sector'],v[i]) for t in report['terrain_triangles'] for i in t['vertices']]
    checks['hills remain inside authored vertical envelope']=min(heights)>=-0.00001 and max(heights)<=spec['terrain']['maximum_height']+0.00001
    checks['both gentle and marked relief exists']=any(0<h<32 for h in heights) and any(h>100 for h in heights)
    checks['hills exist in every exterior direction']=all(any(z(t['sector'],v[t['vertices'][0]])>32 and predicate(v[t['vertices'][0]]) for t in report['terrain_triangles']) for predicate in [lambda p:p['x']<-2464,lambda p:p['x']>1969,lambda p:p['y']<-1420,lambda p:p['y']>640])
    edge_counts=Counter(sides[l[k]]['sector'] for l in newlines for k in ('sidefront','sideback'))
    checks['all terrain sectors have three sides']=all(edge_counts[t['sector']]==3 for t in report['terrain_triangles'])
    partition=report['exterior_partition'];partition_lines=[lines[i] for i in partition['lines']]
    seams=[l for l in partition_lines if l.get('sideback',-1)>=0]
    perimeter=[l for l in partition_lines if l.get('sideback',-1)<0]
    checks['bounded exterior cells cover original horizon footprint']=len(partition['cells'])==9 and sum((c['bounds'][2]-c['bounds'][0])*(c['bounds'][3]-c['bounds'][1]) for c in partition['cells'])==60000**2 and all(max(c['bounds'][2]-c['bounds'][0],c['bounds'][3]-c['bounds'][1])<32768 for c in partition['cells'])
    checks['partition joins stay flat and traversable']=len(seams)==12 and all(l.get('twosided') and not l.get('blocking') and not l.get('special') and all(abs(z(sides[l[side]]['sector'],v[l[end]]))<1e-6 for side in ('sidefront','sideback') for end in ('v1','v2')) for l in seams)
    checks['original blocking horizon remains closed']=len(perimeter)==12 and all(l.get('special')==9 and l.get('blocking') for l in perimeter) and all(count==2 for count in Counter(l[end] for l in perimeter for end in ('v1','v2')).values())
    doors=[t for t in baseline['thing'] if t['type']==spec['tympana']['leaf_editor_number']]
    groups=Counter(t['arg0'] for t in doors)
    checks['exactly one filled tympanum per original door group']=Counter(t['group'] for t in report['tympana'])==Counter({g:1 for g in groups})
    checks['single and double widths match retained leaves']=all(t['width']==groups[t['group']]*spec['tympana']['leaf_width'] for t in report['tympana'])
    checks['tympana start at the actual rendered leaf top']=all(abs(t['bottom']-t['base']-spec['tympana']['leaf_model_height']/spec['tympana']['pixel_stretch'])<.00001 for t in report['tympana'])
    checks['decorative vegetation count']=len(report['vegetation'])==sum(len(spec['vegetation'][k]) for k in ('trees','shrubs'))
    # Locate each placement against the preserved exterior boundary, independently
    # of the generated terrain and its placement report. Pool and cave are holes.
    exterior_boundary=[]
    for line in baseline['linedef']:
        front=baseline['sidedef'][line['sidefront']]['sector']
        back=baseline['sidedef'][line['sideback']]['sector'] if line.get('sideback',-1)>=0 else -1
        if (front==spec['terrain']['sector']) != (back==spec['terrain']['sector']):
            exterior_boundary.append(tuple(baseline['vertex'][line[k]] for k in ('v1','v2')))
    vegetation=spec['vegetation'];margin=vegetation['exclusion_margin']
    plants=[t for t in obj['thing'] if vegetation['first_editor_number']<=t['type']<vegetation['first_editor_number']+4]
    checks['all new vegetation stands on original dry exterior ground']=all(
        sum((a['y']>t['y'])!=(b['y']>t['y']) and t['x']<(b['x']-a['x'])*(t['y']-a['y'])/(b['y']-a['y'])+a['x'] for a,b in exterior_boundary)%2==1 for t in plants)
    checks['all new vegetation clears pool footprint and margin']=all(
        not any(a-margin<=t['x']<=b+margin and c-margin<=t['y']<=d+margin for a,c,b,d in vegetation['excluded_rectangles']) for t in plants)
    models=set(t['model'] for t in report['tympana'])
    model_checks=True
    for model in models:
        text=(ROOT/'src/models/caelum/mansion'/model).read_text()
        verts=[tuple(map(float,line.split()[1:])) for line in text.splitlines() if line.startswith('v ')]
        faces=[line for line in text.splitlines() if line.startswith('f ')]
        surfaces=[line[7:] for line in text.splitlines() if line.startswith('usemtl ')]
        instance=next(t for t in report['tympana'] if t['model']==model)
        model_checks &= len(surfaces)==len(set(surfaces))==2 and all((ROOT/'src'/s).exists() for s in surfaces)
        model_checks &= len(faces)>=6 and min(p[1] for p in verts)==0 and max(p[1] for p in verts)==instance['top']-instance['bottom']
        model_checks &= min(p[0] for p in verts)==-instance['width']/2 and max(p[0] for p in verts)==instance['width']/2
    checks['complete backing dimensions and bounded material surfaces']=model_checks
    closure=report['roof_closure'];roof_spec=spec['tympana']['roof_closure']
    roof_verts=[tuple(map(float,line.split()[1:])) for line in (ROOT/'src/models/caelum/mansion'/closure['model']).read_text().splitlines() if line.startswith('v ')]
    def roof_z(offset):
        x,y=closure['center']
        return min(-(s['floorplane_a']*x+s['floorplane_b']*(y+offset)+s['floorplane_d'])/s['floorplane_c'] for s in (baseline['sector'][i] for i in roof_spec['roof_control_sectors']))
    checks['upper-door gable follows both existing roof slopes']=all(abs(b+closure['base']-roof_z(a))<1e-5 for a,b,c in roof_verts if b>0) and max(b for a,b,c in roof_verts)+closure['base']==closure['ridge']
    checks['upper-door gable fills full width and wall depth']=min(a for a,b,c in roof_verts)==-closure['width']/2 and max(a for a,b,c in roof_verts)==closure['width']/2 and {c for a,b,c in roof_verts}=={-closure['depth']/2,closure['depth']/2} and min(b for a,b,c in roof_verts)==0
    checks['gable starts above the existing ceiling slab without face overlap']=closure['base']==baseline['sector'][roof_spec['ceiling_control_sector']]['heightceiling']
    result=dict(issue=61,map_sha256=report['output_sha256'],checks=checks,maximum_edge_discontinuity=max_jump,maximum_height=max(heights),maximum_slope_degrees=math.degrees(math.atan(report['maximum_gradient'])),errors=[k for k,v in checks.items() if not v])
    print(json.dumps(result,indent=2))
    return bool(result['errors'])


if __name__=='__main__':
    raise SystemExit(main())

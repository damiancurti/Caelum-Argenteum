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
        checks[f'all original {kind} records unchanged']=obj[kind][:len(baseline[kind])]==baseline[kind]
    v,lines,sides,sectors=(obj[k] for k in ('vertex','linedef','sidedef','sector'))
    checks['all references valid']=all(0<=line[k]<len(v) for line in lines for k in ('v1','v2')) and all(0<=line[k]<len(sides) for line in lines for k in ('sidefront','sideback') if line.get(k,-1)>=0) and all(0<=s['sector']<len(sectors) for s in sides)
    checks['no zero length lines']=all(v[l['v1']]!=v[l['v2']] for l in lines)
    newlines=lines[len(baseline['linedef']):]
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
    result=dict(issue=61,map_sha256=report['output_sha256'],checks=checks,maximum_edge_discontinuity=max_jump,maximum_height=max(heights),maximum_slope_degrees=math.degrees(math.atan(report['maximum_gradient'])),errors=[k for k,v in checks.items() if not v])
    print(json.dumps(result,indent=2))
    return bool(result['errors'])


if __name__=='__main__':
    raise SystemExit(main())

"""Check isolation of auxiliary polygons without altering their 3D-floor models."""


def control_checks(obj,baseline,spec,report):
    checks={};expected=set();correct=True;isolated=True;no_overlap=True
    for index,sector in enumerate(spec['sectors']):
        ids={l[k] for l in baseline['linedef'] if baseline['sidedef'][l['sidefront']]['sector']==sector for k in ('v1','v2')}
        expected.update(ids)
        old=[baseline['vertex'][i] for i in ids]
        x=spec['destination_origin'][0]+index%spec['columns']*spec['spacing']
        y=spec['destination_origin'][1]+index//spec['columns']*spec['spacing']
        dx=x-min(p['x'] for p in old);dy=y-min(p['y'] for p in old)
        correct &= all(obj['vertex'][i]==dict(baseline['vertex'][i],x=baseline['vertex'][i]['x']+dx,y=baseline['vertex'][i]['y']+dy) for i in ids)
        p=[obj['vertex'][i] for i in ids];a,b,c,d=min(t['x'] for t in p),min(t['y'] for t in p),max(t['x'] for t in p),max(t['y'] for t in p)
        bounds=spec['playable_bounds'];isolated &= c<bounds[0] or a>bounds[2] or d<bounds[1] or b>bounds[3]
        for line in obj['linedef']:
            if line['v1'] in ids:continue
            ends=[obj['vertex'][line[k]] for k in ('v1','v2')]
            no_overlap &= not (min(t['x'] for t in ends)<=c and max(t['x'] for t in ends)>=a and min(t['y'] for t in ends)<=d and max(t['y'] for t in ends)>=b)
    checks['auxiliary relocation changes only declared vertex translations']=correct and expected=={v for c in report['control_relocations'] for v in c['vertices']}
    checks['relocated auxiliary polygons are outside the playable horizon']=isolated
    checks['relocated auxiliary polygons do not overlap other geometry']=no_overlap
    checks['all original sector planes tags heights light and materials are unchanged']=obj['sector'][:len(baseline['sector'])]==baseline['sector']
    checks['all 3D-floor control lines preserve actions tags and references']=all(obj['linedef'][i]==l for i,l in enumerate(baseline['linedef']) if l.get('special')==160)
    # Identify every detached model, rather than validating only the moved list.
    all_models={obj['sidedef'][l['sidefront']]['sector'] for l in obj['linedef'] if l.get('special')==160}
    def outside(sector):
        pts=[obj['vertex'][l[k]] for l in obj['linedef'] if obj['sidedef'][l['sidefront']]['sector']==sector for k in ('v1','v2')]
        a,b,c,d=spec['playable_bounds']
        return max(p['x'] for p in pts)<a or min(p['x'] for p in pts)>c or max(p['y'] for p in pts)<b or min(p['y'] for p in pts)>d
    checks['every detached 3D-floor control model is outside playable bounds']=all(outside(s) for s in all_models)
    return checks

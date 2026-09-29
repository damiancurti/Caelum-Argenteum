"""Read-only geometry and scope checks for the issue #36 mansion repair."""
from pathlib import Path
import hashlib
import json
import re
from repair_map01_mansion import read_map, tags

ROOT=Path(__file__).resolve().parents[2]
DATA=ROOT/'assets/map01_mansion'


def main():
    config=json.loads((DATA/'REPAIR.json').read_text(encoding='utf-8'))
    manifest=json.loads((DATA/'GENERATED.json').read_text(encoding='utf-8'))
    before=read_map(DATA/config['baseline'])
    after=read_map(ROOT/'src/maps/MAP01.wad')
    checks=[]
    def check(name,value):
        checks.append({'name':name,'passed':bool(value)})
    check('output matches regeneration manifest',hashlib.sha256((ROOT/'src/maps/MAP01.wad').read_bytes()).hexdigest()==manifest['output_sha256'])
    check('all original things preserved except explicit hinged-door type',all(
        dict(t,type=config['hinged_door_type'])==after['thing'][i] if t['type']==18025 else t==after['thing'][i]
        for i,t in enumerate(before['thing'])) and len(before['thing'])==len(after['thing']))
    check('all playable original vertices unchanged',after['vertex'][:len(before['vertex'])]==before['vertex'])
    check('original planes, slopes, lighting, liquids and cave unchanged',all(
        {k:v for k,v in s.items() if k!='moreids'}=={k:v for k,v in after['sector'][i].items() if k!='moreids'}
        for i,s in enumerate(before['sector'])))
    check('all original tags retained',all(tags(s)<=tags(after['sector'][i]) for i,s in enumerate(before['sector'])))
    check('original door, lift, travel and other non-floor specials retained',all(
        all(after['linedef'][i].get(k,0)==line.get(k,0) for k in ['special','arg0','arg1','arg2','arg3','arg4'])
        for i,line in enumerate(before['linedef']) if i not in config['horizon_lines'] and line.get('special',0)!=160))
    check('four horizon boundaries remain one-sided and blocking',all(
        after['linedef'][i].get('special')==9 and after['linedef'][i].get('blocking') and after['linedef'][i].get('sideback',-1)<0
        for i in config['horizon_lines']))
    check('existing rail lines unchanged',all(after['linedef'][i]==before['linedef'][i] for i,z in manifest['existing_rails']))
    check('all railing faces visible and have native 3D collision',all(
        after['linedef'][i].get('midtex3d') and after['linedef'][i].get('dontpegbottom') and
        all(after['sidedef'][after['linedef'][i][side]].get('texturemiddle')=='CMRLBAL' for side in ['sidefront','sideback'])
        for i,z in manifest['new_rails']+manifest['existing_rails']))
    check('reliefs do not introduce blockers or gameplay actors',all(
        not any(after['linedef'][r['line']].get(flag,False) for flag in ['blocking','blockplayers','blockmonsters','midtex3d'])
        for r in manifest['reliefs']))
    check('all shutters have a finite raised sill and no collision',all(
        w['bottom']==w['wall_base']+config['window_panel']['sill'] and
        not after['linedef'][w['line']].get('midtex3d',False) and
        after['sidedef'][after['linedef'][w['line']]['sidefront']]['texturemiddle']==config['window_panel']['texture']
        for w in manifest['windows']))
    ceiling=config['ceiling']
    ceiling_models=[after['sector'][after['sidedef'][line['sidefront']]['sector']] for line in after['linedef']
                    if line.get('special')==160 and line.get('arg0')==ceiling['tag']]
    check('upper ceiling is flat at existing wall tops',len(ceiling_models)==1 and
        ceiling_models[0]['heightfloor']==ceiling['bottom'] and ceiling_models[0]['heightceiling']==ceiling['top'] and
        not any('plane_' in k for k in ceiling_models[0]))
    check('all 52 leaves retain original groups, locks, axes and closed positions',len(manifest['hinged_doors'])==52 and all(
        after['thing'][i]==dict(before['thing'][i],type=config['hinged_door_type']) for i in manifest['hinged_doors']))
    check('opening reconstructions use only four existing door footprints',
        {tuple(s['rectangle']) for s in manifest['door_openings']['sectors']}=={tuple(r) for r in config['door_openings']['rectangles']})
    referenced_sides={line[k] for line in after['linedef'] for k in ('sidefront','sideback') if line.get(k,-1)>=0}
    check('no abandoned sidedefs after doorway subdivision',referenced_sides==set(range(len(after['sidedef']))))
    referenced_sectors={after['sidedef'][i]['sector'] for i in referenced_sides}
    check('every retained sector has an outline',referenced_sectors==set(range(len(after['sector']))))
    for control in config['gable_controls']:
        models=[after['sector'][after['sidedef'][line['sidefront']]['sector']] for line in after['linedef'] if line.get('special')==160 and line.get('arg0')==control['tag']]
        roof=before['sector'][control['roof_control']]
        check(f"gable {control['tag']} meets original roof plane exactly",len(models)==1 and models[0]['heightfloor']==config['gable_base'] and
              all(models[0]['ceilingplane_'+axis]==-roof['floorplane_'+axis] for axis in 'abcd'))
    check('all vertex, side and sector references valid',all(
        0<=l['v1']<len(after['vertex']) and 0<=l['v2']<len(after['vertex']) and
        all(0<=l[k]<len(after['sidedef']) for k in ['sidefront','sideback'] if l.get(k,-1)>=0)
        for l in after['linedef']) and all(0<=s['sector']<len(after['sector']) for s in after['sidedef']))
    report={'issue':36,'map_sha256':manifest['output_sha256'],'checks':checks,'errors':[c['name'] for c in checks if not c['passed']]}
    print(json.dumps(report,indent=2))
    return int(bool(report['errors']))


if __name__=='__main__':
    raise SystemExit(main())

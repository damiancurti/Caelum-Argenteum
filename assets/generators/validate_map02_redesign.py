"""Audit #454's generated collision graph, lock ordering and retained content.

This is static map evidence, not a native physics/escort or performance test.
"""
from collections import Counter, deque
from pathlib import Path
import argparse
import hashlib
import json
import math

ROOT=Path(__file__).resolve().parents[2]

def audit(root=ROOT):
    folder=root/'assets/map02_maze'
    data=json.loads((folder/'LAYOUT.json').read_text(encoding='utf-8'))
    current=json.loads((folder/'MAP02_MANIFEST.json').read_text(encoding='utf-8'))
    previous=json.loads((folder/'legacy_5161/MAP02_MANIFEST.json').read_text(encoding='utf-8'))
    checks=[]
    def check(name,passed):checks.append(dict(check=name,passed=bool(passed)))
    check('revision 6 is active',data['revision']==current['layout_revision']==6)
    check('approved 3 m corridor headroom',data['ceiling']==3*data['units_per_metre'])
    check('96 MU dry shelf fits two maximum players',data['dry_width']>=4*data['largest_player_radius'])
    check('headroom fits the tallest supported actor',data['ceiling']>data['largest_supported_height'])
    check('native model-independent collision dimensions retained',all(data[k]==previous['layout'][k] for k in ['largest_player_radius','largest_prisoner_radius','largest_supported_height']))
    old_counts={k:v for k,v in previous['counts'].items() if k!='rooms'}
    check('all accepted content counts retained',{k:v for k,v in current['counts'].items() if k!='rooms'}==old_counts)
    thing_counts=Counter(t['type'] for t in current['things'])
    check('actual placed populations and chests agree with retained counts',all(thing_counts[k]==v for k,v in {18037:96,18029:192,18038:1,30973:39,30988:1,30989:1,30990:1,30991:1}.items()))
    drop=lambda d:(d['tid'],d['cls'],d['amount'])
    check('every old carrier retains its exact drop identity',sorted(map(drop,current['drops']))==sorted(map(drop,previous['drops'])))
    loot=lambda d:(d['catalogue_index'],d['chest'],d['chest_slot'],d['cls'],tuple(d['args']))
    check('all 65 loot identities and chest assignments retained',sorted(map(loot,current['loot']))==sorted(map(loot,previous['loot'])))
    check('all 45 trap identities/types retained',sorted((t['tid'],t['type']) for t in current['traps'])==sorted((t['tid'],t['type']) for t in previous['traps']))
    check('one keyless internal shortcut per sector',Counter(g['zone'] for g in current['gates'] if g['role']=='maintenance' and g['lock']==0)==Counter(range(4)))
    for section in data['sections']:
        nodes=section['nodes'];graph={i:set() for i in range(len(nodes))}
        for a,b in section['edges']:graph[a].add(b);graph[b].add(a)
        seen={section['entry']};queue=deque(seen)
        while queue:
            for neighbor in graph[queue.popleft()]-seen:seen.add(neighbor);queue.append(neighbor)
        check(section['name']+' principal graph connected',len(seen)==len(nodes))
        check(section['name']+' has three main circuits',len(section['edges'])-len(nodes)+1==3)
    cell=data['grid'];radius=data['largest_player_radius'];height=data['largest_supported_height']
    upper={(row[0],row[1]):row[2:] for row in current['upper_cells']}
    # Sample cell centers and conservatively require the whole actor footprint
    # to stay in contiguous upper-floor cells. Pits are not teleport shortcuts.
    floor_cells={point for point,value in upper.items() if value[0]>=-data['channel_depth'] and value[1]-max(0,value[0])>=height}
    offsets=range(-math.ceil(radius/cell),math.ceil(radius/cell)+1)
    walkable={p for p in floor_cells if all((p[0]+dx*cell,p[1]+dy*cell) in floor_cells
                for dx in offsets for dy in offsets if abs(dx)*cell<radius+cell/2 and abs(dy)*cell<radius+cell/2)}
    def point(position):return (math.floor(position[0]/cell)*cell,math.floor(position[1]/cell)*cell)
    def flood(open_tags):
        blocked=set()
        for gate in current['gates']:
            if gate['tag'] in open_tags:continue
            gx,gy=gate['center'];w=gate['width']/2
            for p in walkable:
                x,y=p[0]+cell/2,p[1]+cell/2
                if gate['axis']=='x' and abs(x-gx)<=radius and abs(y-gy)<=w+radius or gate['axis']=='y' and abs(y-gy)<=radius and abs(x-gx)<=w+radius:blocked.add(p)
        seen={point(data['player_start'])};queue=deque(seen)
        while queue:
            x,y=queue.popleft()
            for other in [(x-cell,y),(x+cell,y),(x,y-cell),(x,y+cell)]:
                if other in walkable and other not in blocked and other not in seen:seen.add(other);queue.append(other)
        return seen
    open_tags={g['tag'] for g in current['gates'] if g['lock']==0}
    boss_gate=44703
    for z in range(4):
        reachable=flood(open_tags)
        for key in [d for d in current['drops'] if d['zone']==z and 'Key' in d['cls']]:
            check(f'stage {z}: {key["cls"]} reachable',point(key['position']) in reachable)
        for future in range(z+1,4):
            key=next(d for d in current['drops'] if d['zone']==future and 'CellKey' in d['cls'])
            check(f'stage {z}: future section {future} remains locked',point(key['position']) not in reachable)
        check(f'stage {z}: boss remains behind P4',point(current['boss_center']) not in reachable)
        open_tags.add(44710+z)
        reachable=flood(open_tags)
        check(f'stage {z}: freed prisoner is reachable',point(current['prisoners'][z]['reserved_actor']) in reachable)
        if z<3:open_tags.add(44700+z)
    reachable=flood(open_tags)
    check('prisoner extraction reachable before P4',point(current['extraction']) in reachable)
    for key,position in current['travel'].items():check(f'service exit {key} reachable before P4 geometry',point(position) in reachable)
    open_tags.add(boss_gate);reachable=flood(open_tags)
    check('boss and card reachable after final key',all(point(current[key]) in reachable for key in ['boss_center','card']))
    check('all four refuges reachable',all(point(r['center']) in reachable for r in current['refuges']))
    for drop in current['drops']:
        check(f'drop carrier {drop["tid"]} is reachable',point(drop['position']) in reachable)
    for chest in [t for t in current['things'] if t['type']==30973]:
        check(f'chest {chest["id"]} is reachable',point([chest['x'],chest['y']]) in reachable)
    for trap in current['traps']:
        if trap['type']=='pit':check(f'pit {trap["tid"]} has a recovery branch',any(p['trap']==trap['tid'] for p in current['layout']['return_network']['paths']))
    provenance=json.loads((folder/'legacy_5161/PROVENANCE.json').read_text(encoding='utf-8'))
    for name,record in provenance['files'].items():
        check('preserved source checksum: '+name,hashlib.sha256((folder/'legacy_5161'/name).read_bytes()).hexdigest()==record['sha256'])
    return {'issue':454,'scope':__doc__.strip(),'checks':checks,'failures':sum(not c['passed'] for c in checks),
            'walkable_upper_cells':len(walkable),'reachable_after_all_keys':len(reachable)}

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path);args=parser.parse_args()
    result=audit()
    if args.output:args.output.parent.mkdir(parents=True,exist_ok=True);args.output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({k:v for k,v in result.items() if k not in ['checks','scope']}))
    for check in result['checks']:
        if not check['passed']:print('FAIL:',check['check'])
    return int(result['failures']>0)

if __name__=='__main__':raise SystemExit(main())

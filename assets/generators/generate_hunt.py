"""Build the approved distributed hunt maze and its bounded navigation index."""
from pathlib import Path
from collections import deque
import hashlib
import json
import random
import sys
sys.dont_write_bytecode = True
from generate_arenas import maze_cells
from generate_coastal_trials import CoastalMap
from generate_tarot_justice import append_arena
from hunt_arcana_geometry import ArcanaGeometry

ROOT = Path(__file__).resolve().parents[2]

def generate():
    settings = json.loads((ROOT/'assets/hunt/LAYOUT.json').read_text(encoding='utf-8'))
    cell = settings['corridor_m']*settings['units_per_metre']
    size = settings['width_m']//settings['corridor_m']
    half = size//2
    cells = set()
    traps = []
    # Each quarter has its own maze and perimeter loop, with several joins.
    for quarter in range(4):
        ox, oy = (quarter%2)*half, (quarter//2)*half
        cells.update((x+ox,y+oy) for x,y in maze_cells(half,settings['seed']+quarter))
        for ordinal,(x,y) in enumerate(( (x,y) for y in (10,22) for x in (8,16,24) )):
            cx,cy=x+ox,y+oy
            # An eight-metre chamber supplies a bypass around the 4m trap.
            cells.update((xx,yy) for xx in range(cx-2,cx+2) for yy in range(cy-2,cy+2))
            traps.append(dict(kind=ordinal%3,cell=[cx,cy],quarter=quarter,tag=6010+len(traps)))
    # Small opposite foyers hold eight non-overlapping starts/captivity places.
    for ox,oy in ((0,0),(size-4,size-4)):
        cells.update((x,y) for x in range(ox,ox+4) for y in range(oy,oy+4))
    arcana=ArcanaGeometry(half,cell)
    arcana.expand(cells)
    ordered=sorted(cells)
    ids={p:i for i,p in enumerate(ordered)}
    blocked={ (x,y) for t in traps for x in range(t['cell'][0]-1,t['cell'][0]+1) for y in range(t['cell'][1]-1,t['cell'][1]+1) }
    blocked.update(arcana.reserved)
    # Spread objectives by farthest-point selection, independently per quarter.
    essences=[]
    for quarter,count in enumerate(settings['essences_per_sector']):
        candidates=[p for p in ordered if (p[0]//half+2*(p[1]//half))==quarter and p not in blocked
                    and not (p[0]<4 and p[1]<4) and not(p[0]>=size-4 and p[1]>=size-4)]
        picked=[]
        for _ in range(count):
            point=max(candidates,key=lambda p:(min(((p[0]-q[0])**2+(p[1]-q[1])**2 for q in picked),default=1),p))
            picked.append(point);candidates.remove(point)
        essences.extend(picked)
    assert len(essences)==78 and len(set(essences))==78
    # All routes remain connected even if all trap footprints are unavailable.
    free=cells-blocked;seen={next(iter(free))};todo=deque(seen)
    while todo:
        x,y=todo.popleft()
        for p in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
            if p in free and p not in seen:seen.add(p);todo.append(p)
    assert seen==free,'Trap footprints must not cut off routes'
    layout=CoastalMap(settings['map']);layout.compact=True;layout.add_default_things=False
    for x,y in ordered:layout.room(x*cell,y*cell,(x+1)*cell,(y+1)*cell,flat=settings['floor'],wall=settings['wall'],light=settings['light'])
    for t in traps:
        cx,cy=t['cell']
        for x in range(cx-1,cx+1):
            for y in range(cy-1,cy+1):
                # Tag only: no control volume. The native plane mover owns it.
                layout.room(x*cell,y*cell,(x+1)*cell,(y+1)*cell,flat=settings['floor'],wall=settings['wall'],light=settings['light'],volume=t['tag'])
    arcana.apply(layout)
    starts=[(cell*(x+.5),cell*(y+.5),0) for y in (1,2) for x in range(4)]
    for slot,(x,y,z) in enumerate(starts):layout.prop(slot+1 if slot<4 else 4001+slot-4,x,y,45)
    def finish(groups):
        arcana.finish(groups)
        for line in groups['linedef']:
            if line.get('special')=='9':line.pop('special')
    layout.transform_groups=finish;layout.write(ROOT/'src/maps')
    arcana.write()
    path=ROOT/'src/maps'/f'{settings["map"]}.wad'
    arena=json.loads((ROOT/'assets/tarot_justice/ARENA.json').read_text())
    blob,justice=append_arena(path.read_bytes(),arena);path.write_bytes(blob)
    lines=['// #601: generado desde assets/hunt/LAYOUT.json.','class CaelumHuntData : Object','{',
           f'    const NODE_COUNT={len(ordered)};',f'    const GRID={size};',f'    const CELL={cell};',
           f'    const REARM_TICS={settings["rearm_seconds"]}*35;',f'    const RESCUE_TICS={settings["rescue_seconds"]}*35;',
           f'    const PATH_RETRY_TICS={settings["path_retry_tics"]};',f'    const PIT_DEPTH={settings["trap_depth_mu"]};',
           f'    const CRUSHER_SPEED={settings["crusher_speed_mu_tic"]};',f'    const DOOR_SPEED={settings["door_speed_arg"]};',
           f'    const DOOR_WAIT={settings["door_wait_arg"]};',f'    const JUSTICE_SECTOR={justice["sector"]};',
           f'    static clearscope String Map(){{return "{settings["map"]}";}}']
    def table(name,typ,rows,default):
        if typ.startswith('vector'):
            dimensions=int(typ[-1])
            values=[row.strip('()').split(',') for row in rows]
            lines.append(f'    static clearscope {typ} {name}(int i){{')
            for axis in range(dimensions):
                lines.append(f'        static const double axis{axis}[]={{'+','.join(v[axis] for v in values)+'};')
            lines.append(f'        return i>=0 && i<{len(rows)}?('+','.join(f'axis{a}[i]' for a in range(dimensions))+f'):{default};')
            lines.append('    }')
            return
        lines.extend([f'    static clearscope {typ} {name}(int i){{',f'        static const {typ} data[]={{'+','.join(rows)+'};',f'        return i>=0 && i<{len(rows)}?data[i]:{default};','    }'])
    table('GridNode','int',[str(ids.get((x,y),-1)) for y in range(size) for x in range(size)],'-1')
    trap_by_cell={ (x,y):i for i,t in enumerate(traps) for x in range(t['cell'][0]-1,t['cell'][0]+1) for y in range(t['cell'][1]-1,t['cell'][1]+1) }
    table('NodeTrap','int',[str(trap_by_cell.get(p,-1)) for p in ordered],'-1')
    table('Node','vector2',[f'({(x+.5)*cell:g},{(y+.5)*cell:g})' for x,y in ordered],'(0,0)')
    table('EssenceNode','int',[str(ids[p]) for p in essences],'-1')
    table('Start','vector3',[f'({x:g},{y:g},0)' for x,y,_ in starts],'(0,0,0)')
    table('TrapPoint','vector3',[f'({t["cell"][0]*cell},{t["cell"][1]*cell},0.5)' for t in traps],'(0,0,0)')
    table('TrapKind','int',[str(t['kind']) for t in traps],'-1')
    table('TrapSector','int',[str(t['tag']) for t in traps],'-1')
    lines += ['    static clearscope int At(vector2 p){int x=int(Floor(p.X/CELL)),y=int(Floor(p.Y/CELL));return x<0 || y<0 || x>=GRID || y>=GRID?-1:GridNode(y*GRID+x);}',
              f'    static clearscope vector3 HunterStart(){{return ({(size-2)*cell},{(size-2)*cell},0);}}',
              f'    static clearscope vector3 JusticeCenter(){{return ({justice["center"][0]:g},{justice["center"][1]:g},0);}}','}']
    (ROOT/'src/caelum/data/CaelumHuntData.zs').write_text('\n'.join(lines)+'\n',encoding='utf-8',newline='\n')
    info=f'map {settings["map"]} "$CA_HUNT_MAP" {{ cluster=0 nointermission teamdamage=0 UnFreezeSinglePlayerConversations music="{settings["music"]}" }}\n'
    (ROOT/'src/caelum/data/hunt.mapinfo').write_text(info,encoding='utf-8',newline='\n')
    report=dict(issue=616,nodes=len(ordered),reachable_without_traps=len(seen),essences=[list(p) for p in essences],traps=traps,arcana=arcana.rooms,justice=justice,map_sha256=hashlib.sha256(blob).hexdigest())
    (ROOT/'assets/hunt/GENERATED.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print('Hunt:',len(ordered),'nodes;',len(seen),'reachable with traps blocked;',len(traps),'traps')

if __name__=='__main__':generate()

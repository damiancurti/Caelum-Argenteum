"""Build the two approved #438 venues with deterministic owned geometry."""
from pathlib import Path
import json
import random
import sys

sys.dont_write_bytecode = True
from generate_coastal_trials import CoastalMap
from generate_environment_models import Mesh

ROOT = Path(__file__).resolve().parents[2]


def maze_cells(size: int, seed: int) -> set[tuple[int, int]]:
    """Carve connected two-metre corridors, leaving full-width separating walls."""
    rng = random.Random(seed)
    visited = {(1, 1)}
    cells = {(1, 1)}
    stack = [(1, 1)]
    while stack:
        x, y = stack[-1]
        choices = [(x+dx, y+dy) for dx, dy in ((2, 0), (0, 2), (-2, 0), (0, -2))
                   if 0 < x+dx < size-1 and 0 < y+dy < size-1 and (x+dx, y+dy) not in visited]
        if not choices:
            stack.pop()
            continue
        target = rng.choice(choices)
        cells.add(((x+target[0])//2, (y+target[1])//2))
        cells.add(target)
        visited.add(target)
        stack.append(target)
    # The continuous outer passage fixes the full approved 64 m footprint.
    for n in range(size):
        cells.update(((0,n),(size-1,n),(n,0),(n,size-1)))
    return cells


def generate() -> None:
    data = json.loads((ROOT / "assets/arenas/VENUES.json").read_text(encoding="utf-8"))
    info = []
    for venue in data["venues"]:
        size = venue["size_m"] * data["units_per_metre"]
        layout = CoastalMap(venue["map"])
        layout.compact = True
        layout.add_default_things = False
        if "passage_m" in venue:
            cell = venue["passage_m"] * data["units_per_metre"]
            for x, y in sorted(maze_cells(size//cell, venue["seed"])):
                layout.room(x*cell, y*cell, (x+1)*cell, (y+1)*cell,
                            flat=venue["floor"], wall=venue["wall"], light=data["light"])
        else:
            layout.room(0, 0, size, size, flat=venue["floor"], wall=venue["wall"], light=data["light"])
            layout.prop(data['ring_frame_visual_only']['editor_number'],size/2,size/2,0)
        for slot, (x, y, angle) in enumerate(venue["starts"]):
            assert (x//64*64, y//64*64) in layout.cells
            layout.prop(slot+1 if slot<4 else 4001+slot-4, x, y, angle)

        def finish(groups):
            for sector in groups["sector"]:
                sector["heightceiling"] = str(data["headroom"])
                sector["textureceiling"] = '"'+venue["ceiling"]+'"'
            for line in groups["linedef"]:
                if line.get("special") == "9":
                    line.pop("special")
        layout.transform_groups = finish
        layout.write(ROOT / "src/maps")
        info.append(f'map {venue["map"]} "${venue["name_key"]}" {{ cluster=434 nointermission teamdamage=1 UnFreezeSinglePlayerConversations music="{venue["music"]}" }}')

    native = ["// #438: generado desde assets/arenas/VENUES.json.",
              "class CaelumArenaData : Object", "{", "    const REVISION=1;", "    const CONVERSATION=43800;",
              "    static clearscope String Map(int venue) { switch(venue) {"]
    for index, venue in enumerate(data["venues"]):
        native.append(f'        case {index}: return "{venue["map"]}";')
    native += ['    } return ""; }', '    static clearscope String NameKey(int venue) { switch(venue) {']
    for index, venue in enumerate(data["venues"]):
        native.append(f'        case {index}: return "{venue["name_key"]}";')
    native += ['    } return "CA_ARENA_TITLE"; }', '    static clearscope bool IsMap(String map) { return map==Map(0) || map==Map(1); }',
               '    static clearscope vector3 Start(int venue,int slot) { switch(venue*MAXPLAYERS+slot) {']
    for index, venue in enumerate(data["venues"]):
        for slot, (x, y, _) in enumerate(venue["starts"]):
            native.append(f'        case {index*8+slot}: return ({x},{y},0);')
    native += ['    } return (0,0,0); }', '    static clearscope double Facing(int venue,int slot) { switch(venue*MAXPLAYERS+slot) {']
    for index, venue in enumerate(data["venues"]):
        for slot, (_, _, angle) in enumerate(venue["starts"]):
            native.append(f'        case {index*8+slot}: return {angle};')
    npc = data["organizer"]
    native += ['    } return 0; }', f'    static clearscope vector3 OrganizerPosition() {{ return ({",".join(map(str,npc["position"]))}); }}',
               f'    const ORGANIZER_ANGLE={npc["angle"]};', f'    static clearscope String OrganizerMap() {{ return "{npc["map"]}"; }}', '}']
    (ROOT / "src/caelum/data/CaelumArenaData.zs").write_text("\n".join(native)+"\n", encoding="utf-8", newline="\n")
    art=data['ring_frame_visual_only'];units=data['units_per_metre']
    mesh=Mesh('CaelumArenaRingFrame');half=data['venues'][0]['size_m']/2-art['post_inset_m']
    corners=[(-half,-half),(half,-half),(half,half),(-half,half)]
    for i,(x,z) in enumerate(corners):
        mesh.add_frustum(art['wood'],(x,0,z),(x,art['post_height_m'],z),art['post_radius_m'],art['post_radius_m'],art['sides'])
        other=corners[(i+1)%len(corners)]
        for height in art['rope_heights_m']:
            mesh.add_frustum(art['rope'],(x,height,z),(other[0],height,other[1]),art['rope_radius_m'],art['rope_radius_m'],art['sides'])
    mesh.vertices=[(x*units,y*units*art['pixel_stretch_compensation'],z*units) for x,y,z in mesh.vertices]
    mesh.faces.sort(key=lambda entry:entry[0])
    target=ROOT/'src/models/caelum/world/arenas';target.mkdir(parents=True,exist_ok=True)
    mesh.write(target/'ring_frame.obj')
    model=target/'ring_frame.obj'
    model.write_text(model.read_text(encoding='utf-8'),encoding='utf-8',newline='\n')
    info.append(f'DoomEdNums {{ {art["editor_number"]}=CaelumArenaRingFrame }}')
    (ROOT / "src/caelum/data/arenas.mapinfo").write_text("\n".join(info)+"\n", encoding="utf-8", newline="\n")
    # A MAPINFO redefinition resets omitted properties, not just the cluster.
    standalone=['// Datos compartidos con las arenas; cambia solamente el hub.',
                'gameinfo { PlayerClasses = "CaelumStandalonePlayer" }']
    standalone.extend(line.replace('cluster=434','cluster=0') for line in info if line.startswith('map '))
    (ROOT / "src/caelum/data/standalone.mapinfo").write_text("\n".join(standalone)+"\n",encoding="utf-8",newline="\n")


if __name__ == "__main__":
    generate()

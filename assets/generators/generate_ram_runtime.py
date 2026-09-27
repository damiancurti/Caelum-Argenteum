#!/usr/bin/env python3
"""Generate #20 component meshes and physical data; preserve the #18 gallery."""
import json
import math
from pathlib import Path

from generate_siege_models import ram_state, Mesh, IRON, make_transparent_sprite, SPEC

ROOT = Path(__file__).resolve().parents[2]
DATA = json.loads(Path(__file__).with_name('ram_physics.json').read_text(encoding='utf-8'))
U = SPEC['map_units_per_metre']


def generate():
    # Match the existing sixteen-sided solid log/head, three hollow bands,
    # six handles and end plate. No frame, wheels or crew enter this mass.
    polygon = 8 * math.sin(math.tau / 16)
    wood_volume = polygon * 11**2 * 112 + 6 * 4 * 4 * 17
    iron_volume = polygon * (12**2 + 12*14 + 14**2) * 10 / 3
    iron_volume += 4 * 25 * 25 + 3 * polygon * (11.7**2 - 11**2) * 4
    moving_mass = (wood_volume * DATA['oak_kg_m3'] + iron_volume * DATA['iron_kg_m3']) / U**3
    scale = (DATA['large_crew'] / DATA['small_crew'])**(1/3)
    # Coarse transport-only estimate: beams/wheels/axles; overlaps and voids
    # imply uncertainty. Never used by the striking assembly's damage path.
    frame_wood = 2*150*8*8 + 2*8*8*70 + 4*70*6*6 + 2*9*7*38 + 2*110*4*4
    frame_wood += 4 * math.pi * 15**2 * 7
    frame_iron = 2 * math.pi * 2**2 * 84 + 4*7*8*7
    frame_mass = (frame_wood*DATA['oak_kg_m3'] + frame_iron*DATA['iron_kg_m3']) / U**3

    def threshold(reduction, gate_mass):
        toughness = (math.sqrt(1 + 20200 * reduction / (1-reduction)) - 1) / 2
        delta = .8 * math.sqrt(1 + 1224 * toughness / 100)
        return delta * (moving_mass + gate_mass) / moving_mass

    speed = (threshold(.5, 650) + threshold(.7, 1100)) / 2
    suspension = (SPEC['ram']['suspension_top_y'] - 3 - 49) / U
    period = 2 * math.pi * math.sqrt(suspension / DATA['gravity_m_s2'])
    values = {
        'SMALL_CREW': DATA['small_crew'], 'LARGE_CREW': DATA['large_crew'],
        'LARGE_SCALE': scale, 'MOVING_MASS': moving_mass, 'FRAME_MASS': frame_mass,
        'STRIKE_SPEED': speed, 'APPROACH_SPEED': DATA['approach_m_s'] * U / 35,
        'RECOVERY_TICS': math.ceil(period * 35), 'RETRACT': -16.0, 'EXTENDED_OFFSET': 28.0,
        'HEAD_X': 32.0, 'HEAD_Z': 30.0, 'HEAD_RADIUS': 2.0, 'HEAD_HEIGHT': 28.0,
        'FRAME_REAR': -91.0, 'FRAME_FRONT': 59.0, 'FRAME_HALF_WIDTH': 42.0,
        'FRAME_HEIGHT': 91.5, 'GUARD_RADIUS': 150.0 * DATA['proximity_machine_lengths'],
        'SWEEP_STEP': .5, 'MU_PER_METRE': U,
        'FRAME_COLUMNS': 8, 'FRAME_ROWS': 5, 'BLOCK_RADIUS': 10.0,
        'FRAME_STEP_X': 130/7, 'FRAME_STEP_Y': 16.0,
        'FACE_BLOCKS': 8, 'FACE_START_Y': -10.5, 'FACE_STEP_Y': 3.0,
        'ROD_REAR_X': -62.0, 'ROD_FRONT_X': 12.0, 'ROD_Y': 9.0,
        'ROD_BOTTOM_Z': 49.0, 'ROD_TOP_Z': 85.0,
        'TRIAL_FIRST_X': DATA['trial']['first_x'], 'TRIAL_SPACING_X': DATA['trial']['spacing_x'],
        'TRIAL_START_Y': DATA['trial']['start_y'], 'TRIAL_GATE_Y': DATA['trial']['gate_y'],
        'TRIAL_LANES': DATA['trial']['lanes'], 'TRIAL_CREW_SIDE':90.0,
        'TRIAL_CREW_REAR': -105.0, 'TRIAL_CREW_STEP': 28.0,
        'TRIAL_CONTACT_DISTANCE': 62.0,
    }
    lines = ['// Generado por generate_ram_runtime.py; datos y fuentes en ram_physics.json.',
             'class CaelumRamData : Object', '{']
    lines += [f'    const {k} = {v if isinstance(v, int) else format(v, ".12f")};' for k,v in values.items()]
    lines += ['}', '']
    (ROOT/'src/caelum/world/CaelumRamData.zs').write_text('\n'.join(lines), encoding='utf-8')
    folder = ROOT/'src/models/caelum/siege'
    for component in ('frame', 'moving'):
        ram_state('ca_ram_'+component, 0, component).write(folder/f'ca_ram_{component}.obj')
    rod = Mesh('ca_ram_suspension')
    rod.add_frustum(IRON, (0,0,0), (1,0,0), .9/36, .9/36, 8)
    rod.write(folder/'ca_ram_suspension.obj')
    actors = [('CaelumRamFrameVisual','frame','CRFR'), ('CaelumRamHead','moving','CRHD'),
              ('CaelumRamSuspension','suspension','CRSP')]
    begin, end = '// BEGIN GENERATED RAM COMPONENTS', '// END GENERATED RAM COMPONENTS'
    path = ROOT/'src/MODELDEF'
    text = path.read_text(encoding='utf-8')
    if begin in text:
        prefix, rest = text.split(begin,1); _, suffix = rest.split(end,1)
    else:
        prefix, suffix = text.rstrip()+'\n\n', '\n'
    bindings = [begin]
    for actor, component, sprite in actors:
        make_transparent_sprite(ROOT/f'src/sprites/{sprite}A0.png')
        bindings += [f'Model {actor}', '{', '    Path "models/caelum/siege"',
                     f'    Model 0 "ca_ram_{component}.obj"', '    Scale 1 1 1',
                     '    CorrectPixelStretch', '    DontCullBackFaces',
                     '    InheritActorPitch', f'    FrameIndex {sprite} A 0 0', '}']
    path.write_text(prefix+'\n'.join(bindings)+'\n'+end+suffix,encoding='utf-8')
    report = {'derived': values, 'moving_wood_kg': wood_volume*DATA['oak_kg_m3']/U**3,
              'moving_iron_kg': iron_volume*DATA['iron_kg_m3']/U**3,
              'large_moving_kg': moving_mass*scale**3, 'strike_m_s': speed*35/U,
              'large_dimensions_scale': scale, 'recovery_seconds':period,
              'uncertainty': 'Reconstruction, not measured machinery: oak moisture variation; pure-iron density approximates historical metal; transport envelope estimate includes overlapping members and filled wheel voids. Large size scales moving mass per operator equally. Stroke and speed are game choices, not historical measurements.'}
    out = ROOT/'assets/validation_43616'
    out.mkdir(exist_ok=True)
    (out/'ram_inputs.json').write_text(json.dumps(report, indent=2)+'\n',encoding='utf-8')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    generate()

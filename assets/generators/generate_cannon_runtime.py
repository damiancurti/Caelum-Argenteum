"""Generate approximate #21 cannon components and authoritative physical data."""
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
D = json.loads(Path(__file__).with_name('cannon_physics.json').read_text(encoding='utf-8'))
U, T = D['map_units_per_metre'], D['native_tics_per_second']

def generate():
    from generate_siege_models import Mesh, IRON, WOOD, INSIDE, BRASS, add_box, add_beam, add_wheel, add_tube, make_transparent_sprite
    wheel = D['wheel_diameter_m_estimate'] * U / 2
    track = D['track_m_estimate'] * U
    pivot = D['trunnion_height_m_estimate'] * U
    muzzle = D['muzzle_forward_m_estimate'] * U
    rear = muzzle - D['barrel_length_m_estimate'] * U
    trail = D['trail_length_m_estimate'] * U
    frame = Mesh('ca_cannon_frame')
    for side in (-1, 1):
        add_beam(frame, IRON, (-trail, 3, side*5), (0, wheel, side*11), 5, 4)
        add_box(frame, IRON, (0, (wheel+pivot)/2, side*9), (14, pivot-wheel+5, 4))
        add_wheel(frame, (0, wheel, side*track/2), wheel, 4)
    frame.add_frustum(IRON, (0,wheel,-track/2), (0,wheel,track/2), 1.5,1.5,12)
    add_box(frame, IRON, (-trail,2,0), (8,4,16))
    add_beam(frame, IRON, (-14,12,0), (-14,pivot-4,0), 2,2)
    meshes=[frame]
    for state, opened in [('closed',False),('open',True)]:
        mesh=Mesh('ca_cannon_'+state)
        mesh.add_frustum(IRON,(rear,0,0),(0,0,0),4.5,4,24)
        mesh.add_frustum(IRON,(0,0,0),(muzzle-3,0,0),4,2.2,24)
        add_tube(mesh,IRON,(muzzle-3,0,0),(muzzle,0,0),2.2,D['projectile_diameter_m']*U/2)
        mesh.add_frustum(INSIDE,(muzzle-8,0,0),(muzzle,0,0),1.2,1.2,24,True,False)
        mesh.add_frustum(IRON,(0,0,-12),(0,0,12),2,2,16)
        add_box(mesh,IRON,(rear-2,0,0),(5,10,10))
        add_box(mesh,INSIDE,(rear-4.6,0,0),(.2,7,7))
        shift=8 if opened else 0
        add_box(mesh,IRON,(rear-5,0,shift),(2,8,9))
        add_beam(mesh,IRON,(rear-6,0,shift+3),(rear-6,-5,shift+6),1,1)
        add_box(mesh,WOOD,(rear-6,-5,shift+7),(2,2,4))
        meshes.append(mesh)
    shot=Mesh('ca_cannon_round')
    radius=D['projectile_diameter_m']*U/2
    length=D['projectile_length_m']*U
    shot.add_frustum(IRON,(radius-length,radius,0),(radius-length/4,radius,0),radius,radius,16)
    shot.add_frustum(IRON,(radius-length/4,radius,0),(radius,radius,0),radius,0,16)
    meshes.append(shot)
    flash=Mesh('ca_cannon_flash')
    flash.add_frustum(BRASS,(0,0,0),(8,0,0),radius,3,12)
    flash.add_frustum(BRASS,(8,0,0),(16,0,0),3,0,12)
    meshes.append(flash)
    for mesh in meshes:
        mesh.write(ROOT/'src/models/caelum/siege'/f'{mesh.object_name}.obj')
    for name in ['CCFRA0','CCBRA0','CCBRB0','CCSHA0','CCFLA0']:
        make_transparent_sprite(ROOT/'src/sprites'/f'{name}.png')
    generate_data_only()
    p=ROOT/'src/MODELDEF'; s=p.read_text(encoding='utf-8')
    start='// BEGIN GENERATED CANNON COMPONENTS'; end='// END GENERATED CANNON COMPONENTS'
    block=start+'\n'
    for cls, mesh, sprite, frameletter in [('CaelumCannonFrame','ca_cannon_frame','CCFR','A'),('CaelumCannonBarrel','ca_cannon_closed','CCBR','A'),('CaelumCannonBarrel','ca_cannon_open','CCBR','B'),('CaelumCannonProjectile','ca_cannon_round','CCSH','A'),('CaelumCannonFlash','ca_cannon_flash','CCFL','A')]:
        block+=f'Model {cls}\n{{\n    Path "models/caelum/siege"\n    Model 0 "{mesh}.obj"\n    Scale 1 1 1\n    CorrectPixelStretch\n    DontCullBackFaces\n    InheritActorPitch\n    FrameIndex {sprite} {frameletter} 0 0\n}}\n'
    block+=end+'\n'
    if start in s: s=s[:s.index(start)]+block+s[s.index(end)+len(end):].lstrip('\n')
    else: s+='\n'+block
    p.write_text(s,encoding='utf-8')

def generate_data_only():
    """Update physics without importing or rewriting accepted visual assets."""
    wheel = D['wheel_diameter_m_estimate'] * U / 2
    track = D['track_m_estimate'] * U
    muzzle = D['muzzle_forward_m_estimate'] * U
    trail = D['trail_length_m_estimate'] * U
    values = {'SPEED': D['muzzle_speed_m_s']*U/T,
        'PROJECTILE_MASS': D['projectile_mass_kg'], 'RADIUS': D['projectile_diameter_m']*U/2,
        'LENGTH': D['projectile_length_m']*U, 'MACHINE_MASS': D['machine_mass_kg_estimate'],
        'CREW': D['crew'], 'CYCLE': D['cycle_seconds']*T,
        'LEGACY_CYCLE': D['legacy_cycle_seconds']*T, 'RECOVERY': D['recovery_seconds']*T,
        'PIVOT_Z': D['trunnion_height_m_estimate']*U, 'MUZZLE_X': muzzle,
        'BREECH_X': muzzle-D['barrel_length_m_estimate']*U, 'WHEEL_RADIUS': wheel,
        'HALF_TRACK': track/2, 'TRAIL': trail,
        'GUARD_RADIUS': (trail+muzzle)*D['guard_radius_machine_lengths'],
        'RECOIL': D['recoil_presentation_m']*U, 'SPENT_TICS': D['spent_tics'],
        'MAX_FLIGHT_TICS': D['flight_lifetime_seconds']*T}
    values.update({'TRIAL_'+k.upper(): v for k, v in D['trial'].items()})
    code = '// Generado desde cannon_physics.json; aproximación aprobada, no ficha histórica.\nclass CaelumCannonData : Object\n{\n'
    code += ''.join(f'    const {key} = {value:.12g};\n' for key, value in values.items())+'}\n'
    (ROOT/'src/caelum/world/CaelumCannonData.zs').write_text(code, encoding='utf-8')

if __name__=='__main__':
    if '--data-only' in sys.argv: generate_data_only()
    else: generate()

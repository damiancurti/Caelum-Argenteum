"""Build private native house-transition and lifecycle controls."""
from pathlib import Path
import argparse,hashlib,importlib.util,json
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('base',ROOT/'assets/validation_5445/prepare.py')
base=importlib.util.module_from_spec(spec);spec.loader.exec_module(base)
def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--directory',required=True)
    p.add_argument('--cap',type=int,choices=[0,1],default=0)
    p.add_argument('--wipe',type=int,default=1)
    p.add_argument('--roundtrip',action='store_true')
    p.add_argument('--hold',action='store_true')
    p.add_argument('--long-arrival',action='store_true')
    p.add_argument('--vehicle',type=int,choices=[3,4])
    p.add_argument('--early',action='store_true')
    p.add_argument('--lifecycle',choices=['controls','pending','arrival','interrupt','newgame'])
    a=p.parse_args();out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
    members={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
    name='caelum/world/CaelumHouseHub.zs'
    old=b'        Level.ChangeLevel(DestinationMap(),'
    assert members[name].count(old)==1
    members[name]=members[name].replace(old,b'        EventHandler.SendInterfaceEvent(consoleplayer,"c334_queued");\n'+old)
    if a.hold:
        key='caelum/ui/CaelumMenuAudio.zs';old=b'SendNetworkEvent("ca_house_capture_ready",'
        assert members[key].count(old)==1
        members[key]=members[key].replace(old,b'SendNetworkEvent("c334_hold_ready",')
    if a.long_arrival:
        key='caelum/ui/CaelumMenuAudio.zs'
        members[key]=members[key].replace(b'ArrivalFrames<35',b'ArrivalFrames<350').replace(b'ArrivalFrames==35',b'ArrivalFrames==350')
    package=base.base.prior.base.package
    runtime=package(out/'baseline.pk3',members)
    fixture_members={'ZSCRIPT':b'version "4.14"\n#include "probe.zs"\n',
        'probe.zs':(HERE/'trace.zs').read_bytes(),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA353Performance", "CA334NativeTrace" }\n'}
    if a.vehicle:
        vehicle=(ROOT/'assets/validation_5436/house334-vehicle.zs').read_text(encoding='utf-8')
        vehicle=vehicle.replace('ui bool SawHouseOverlay;','ui bool SawHouseOverlay;\n    ui String HouseSource;')
        vehicle=vehicle.replace('if(e.Name=="ca_vehicle_wipe_visible")',
            'if(e.Name=="ca_map_depart" && e.Args[0]==CaelumConstants.TRAVEL_WIPE_HOUSE_DOOR)HouseSource=audio.SnapshotMap;\n        if(e.Name=="ca_vehicle_wipe_visible")')
        vehicle=vehicle.replace('Early?(SawHouseOverlay?1:0):VisibleWipe','Early?(SawHouseOverlay && HouseSource=="MAP03" && VisibleWipe==1?1:0):VisibleWipe')
        vehicle=vehicle.replace('baseline retains previous vehicle overlay inside house','house uses its fresh city capture and Melt')
        fixture_members={'ZSCRIPT':b'version "4.14"\n#include "base.zs"\n#include "house.zs"\n#include "vehicle.zs"\n',
            'base.zs':(ROOT/'assets/validation_5422/probe.zs').read_bytes(),
            'house.zs':(ROOT/'assets/validation_5436/house334-probe.zs').read_bytes(),
            'vehicle.zs':vehicle.encode(),
            'MAPINFO':b'GameInfo { AddEventHandlers="CA334VehicleProbe" }\n'}
    fixture=package(out/'city.pk3',fixture_members)
    seed=ROOT/'build/issue354-preview01/auto03.zds'
    (out/'author.zds').write_bytes(seed.read_bytes())
    manifest=dict(runtime_sha256=runtime,fixture_sha256=fixture,seed_sha256=hashlib.sha256(seed.read_bytes()).hexdigest(),cap=a.cap,wipe=a.wipe,hold=a.hold,vehicle=a.vehicle,early=a.early,long_arrival=a.long_arrival,lifecycle=a.lifecycle,
        effective_cap=1 if a.hold or a.vehicle or a.lifecycle else a.cap,
        effective_wipe=1 if a.lifecycle else 2 if a.vehicle else 3 if a.hold else a.wipe)
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    leg='netevent c334_position; wait 5; +use; wait 10; -use; wait 350; '
    (out/'probe.cfg').write_text(f'vid_vsync false; vid_maxfps 0; cl_capfps {a.cap}; wipetype {a.wipe}; wait 70; '+leg*(3 if a.roundtrip else 1)+'netevent c334_done; wait 5; quit\n')
    if a.hold:
        (out/'probe.cfg').write_text(f'cl_capfps 1; wipetype 3; wait 70; netevent c334_position; wait 5; screenshot before.png; +use; wait 10; -use; wait 5; screenshot source.png; netevent ca_house_capture_ready 1; wait 70; screenshot held-arrival.png; wait 700; screenshot destination.png; netevent c334_done; wait 5; quit\n')
    if a.vehicle:
        (out/'probe.cfg').write_text(f'cl_capfps 1; wipetype 2; wait 100; netevent c334_vehicle_seed {a.vehicle} {int(a.early)} 0; wait 10; netevent c334_board; wait 700; netevent c334_vehiclecheck; wait 15; quit\n')
    if a.lifecycle:
        prefix='cl_capfps 1; wait 70; netevent c334_position; wait 5; '
        cases={
            'controls':'netevent c334_lifecycle_controls; wait 5; quit',
            'pending':'+use; wait 1; -use; wait 5; netevent c334_pending_check; wait 1; save pending; wait 5; load pending; wait 35; netevent ca_house_capture_ready 1; wait 35; netevent c334_cancel_checked 0; wait 5; quit',
            'arrival':'+use; wait 1; -use; wait 5; netevent c334_arrival_check; wait 1; load author.zds; wait 35; netevent ca_house_capture_ready 1; wait 35; netevent c334_cancel_checked 0; wait 5; quit',
            'interrupt':'netevent c334_interrupt_enabled; wait 1; +use; wait 1; -use; wait 350; netevent ca_house_capture_ready 1; wait 35; netevent c334_cancel_checked 2; wait 5; quit',
            'newgame':'+use; wait 1; -use; wait 5; netevent c334_arrival_check; wait 1; map CAH008; wait 70; netevent ca_house_capture_ready 1; wait 35; netevent c334_cancel_checked 0; wait 5; quit'}
        (out/'probe.cfg').write_text(prefix+cases[a.lifecycle]+'\n')
    print(json.dumps(manifest))
if __name__=='__main__':main()

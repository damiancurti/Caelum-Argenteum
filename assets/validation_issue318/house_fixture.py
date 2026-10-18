"""Freeze current sources and the functional house-hub fixture; never overwrite evidence."""
from pathlib import Path
import argparse
import hashlib
import json
import sys
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent


def package(path,members):
    assert not path.exists(), path
    with zipfile.ZipFile(path,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for name,data in sorted(members.items()):
            info=zipfile.ZipInfo(name,(2000,1,1,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED
            z.writestr(info,data)
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True)
    a=p.parse_args();work=ROOT/'build'/a.directory/'current';work.mkdir(parents=True,exist_ok=True)
    sys.path.insert(0,str(ROOT/'assets/generators'))
    import generate_house_hubs
    generate_house_hubs.runtime()
    members={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in sorted((ROOT/'src').rglob('*')) if p.is_file()}
    runtime=package(work/'runtime.pk3',members)
    checks={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
            'checks.zs':(HERE/'house_checks.zs').read_bytes(),
            'MAPINFO':b'GameInfo { AddEventHandlers="CA318HouseChecks" }\n'}
    fixture=package(work/'checks.pk3',checks)
    observer={
        'ZSCRIPT':b'version "4.14"\n#include "observer.zs"\n',
        'observer.zs':(HERE/'observer.zs').read_bytes(),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA318Observer" }\n',
        'CVARINFO':b'server int ca318_phase=0; server int ca318_site=1; server int ca318_pitch=0; server int ca318_window=350; server int ca318_warmup=140; server bool ca318_freeze=false; server bool ca318_save=false;\n'}
    package(work/'observer.pk3',observer)
    scripts={
        'smoke':'wait 70; netevent houses_city; changemap CAH158; wait 70; netevent houses_inside; screenshot house-interior.png; wait 5; netevent houses_seed; changemap MAP06; wait 70; netevent houses_parked; changemap CAH158; wait 70; netevent houses_retained; netevent houses_done; wait 5; quit\n',
        'save':'wait 70; changemap CAH158; wait 70; netevent houses_seed; storesavepic false; save house-state.zds; wait 10; netevent houses_done; wait 5; quit\n',
        'reload':'wait 35; netevent houses_retained; changemap MAP06; wait 70; netevent houses_parked; storesavepic false; save city-state.zds; wait 10; netevent houses_done; wait 5; quit\n',
        'return':'wait 35; changemap CAH158; wait 70; netevent houses_retained; netevent houses_done; wait 5; quit\n',
        'fresh':'wait 70; netevent houses_fresh; wait 70; netevent houses_fresh_checked; changemap MAP06; wait 70; netevent houses_fresh_checked; netevent houses_done; wait 5; quit\n',
        'deploy':'wait 70; netevent houses_defenders_begin; wait 2100; netevent houses_defenders_checked; netevent houses_reassign; changemap CAH158; wait 70; changemap MAP06; wait 70; netevent houses_reassignment_checked; netevent houses_done; wait 5; quit\n',
        'blocked':'wait 70; changemap CAH158; wait 70; netevent houses_block; wait 70; changemap CAH158; wait 70; netevent houses_blocked; wait 35; netevent houses_unblocked; netevent houses_done; wait 5; quit\n',
        'status':'wait 70; changemap CAH158; wait 70; netevent houses_status; changemap MAP06; wait 70; changemap CAH158; wait 70; netevent houses_status_checked; netevent houses_done; wait 5; quit\n',
        'raised':'wait 70; changemap CAH158; wait 70; netevent houses_memory 0; changemap MAP06; wait 70; netevent houses_memory_checked 0; changemap CAH158; wait 70; netevent houses_memory_checked 0; netevent houses_done; wait 5; quit\n',
        'converted':'wait 70; changemap CAH158; wait 70; netevent houses_memory 1; netevent houses_status; changemap MAP06; wait 70; netevent houses_memory_checked 1; netevent houses_status_checked; netevent houses_expire; changemap CAH159; wait 70; netevent houses_memory_checked 0; changemap MAP06; wait 70; netevent houses_dead_checked; netevent houses_done; wait 5; quit\n',
        'dead':'wait 70; changemap CAH158; wait 70; netevent houses_kill; changemap MAP06; wait 70; netevent houses_dead_checked; changemap CAH158; wait 70; netevent houses_dead_checked; netevent houses_done; wait 5; quit\n',
    }
    scripts['growth']='wait 70; netevent houses_defenders_begin; wait 2100; netevent houses_defenders_checked; storesavepic false; save roster600-before.zds; '+''.join(
        f'changemap CAH{house:03d}; wait 10; ' for house in range(10))+        'changemap MAP06; wait 70; save roster600-after10.zds; wait 10; netevent houses_defenders_checked; netevent houses_done; wait 5; quit\n'
    scripts['portals']='wait 70; '+''.join(
        f'netevent houses_position {house}; wait 2; +use; wait 10; -use; wait 35; netevent houses_arrived {house}; '
        f'netevent houses_position {house}; wait 2; +use; wait 10; -use; wait 35; netevent houses_returned {house}; '
        for house in (0,119,120,158,159))+'netevent houses_done; wait 5; quit\n'
    for name,content in scripts.items():(work/(name+'.cfg')).write_text(content,encoding='utf-8')
    (work/'manifest.json').write_text(json.dumps({'runtime_sha256':runtime,'fixture_sha256':fixture,'members':len(members)},indent=2)+'\n')
    print(work, runtime,flush=True)


if __name__=='__main__':main()

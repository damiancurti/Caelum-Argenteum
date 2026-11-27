"""Check launch identities and verifier selection against retained native saves."""
from pathlib import Path
import argparse,ast,hashlib,json,sys

ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT))
from caelum_sessions import manifest,verify_manifest,resource_arguments
from caelum_profiles import ProfileError
from caelum_transfer_verify import checkpoint_candidates

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runtime',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    runtime=a.runtime;engine=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
    addon=ROOT/'build/issue468-anchor01/observer.pk3'
    assert resource_arguments(runtime,[runtime])==['-iwad',str(runtime.resolve())]
    assert resource_arguments(runtime,[runtime,addon])==['-iwad',str(runtime.resolve()),'-file',str(addon)]
    identity=manifest(engine,runtime,[runtime])
    assert len(identity['files'])==5 and identity['explicit_packages']==0
    verify_manifest(identity,engine,runtime.resolve(),[runtime.resolve()])
    try:verify_manifest(identity,engine,runtime,[runtime,addon])
    except ProfileError:pass
    else:raise AssertionError('Changed resources accepted')
    legacy=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
    assert resource_arguments(legacy,[runtime])==['-iwad',str(legacy.resolve()),'-file',str(runtime.resolve())]
    legacy_identity=manifest(engine,legacy,[runtime])
    assert legacy_identity['explicit_packages']==1 and len(legacy_identity['files'])==6
    source=ROOT/'build/issue468-transfer02/outbound/destination/peer0'
    # Two actual native saves caused the old sole-file selection to time out.
    for name in ['save00.zds','save01.zds']:(out/name).write_bytes((source/name).read_bytes())
    title='Caelum verified profile transfer'
    assert checkpoint_candidates(out,title)==[out/'save01.zds']
    (out/'save02.zds').write_bytes(b'Incomplete native writer')
    assert checkpoint_candidates(out,title)==[out/'save01.zds']
    assert checkpoint_candidates(out,title+' stale')==[]
    duplicate=out/'ambiguous';duplicate.mkdir()
    for name in ['save00.zds','save01.zds']:(duplicate/name).write_bytes((source/'save01.zds').read_bytes())
    try:checkpoint_candidates(duplicate,title)
    except ProfileError:pass
    else:raise AssertionError('Ambiguous verification accepted')
    paths=['caelum_sessions.py','caelum_standalone.py','caelum_new_campaign.py','caelum_transfer_verify.py']
    for name in paths:ast.parse((ROOT/name).read_text(encoding='utf8'))
    report=dict(issue=468,passed=True,checks=['primary-only and overlay arguments use absolute paths',
        'independent manifest records five native resources, zero additional packages',
        'equivalent relative/absolute resource identity accepted', 'changed resource identity rejected',
        'development IWAD keeps separate runtime and six-resource manifest',
        'native narrative save retained while verifier checkpoint selected',
        'incomplete native archive ignored while writer finishes','foreign title not selected',
        'ambiguous verification refuses publication','affected Python syntax'],
        sources={name:hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in paths},author_acceptance=False)
    (out/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))

if __name__=='__main__':main()

"""Run immutable #322 fixtures sequentially; retain actual save identities."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import shutil
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory',required=True)
    parser.add_argument('--legacy-save',type=Path)
    parser.add_argument('--campaign',action='store_true')
    parser.add_argument('--start-kind',type=int,choices=range(5),default=0)
    parser.add_argument('--saves-only',action='store_true')
    parser.add_argument('--skip-case',action='append',default=[],help='Retain an already completed case; archive.py still validates every final case.')
    parser.add_argument('--case',action='append',default=[],help='Run only the selected labels in the chosen normal/campaign matrix.')
    args=parser.parse_args()
    if not re.fullmatch(r'issue322-[a-z0-9_-]+',args.directory):parser.error('Expected issue322 directory')
    folder=ROOT/'build'/args.directory
    path=folder/'files.json'
    records=json.loads(path.read_text()) if path.exists() else []
    def run(label,script=None,map_name='MAP99',load=None):
        if args.case and label not in args.case:return
        if label in args.skip_case:
            if not (folder/(label+'-run.json')).exists():raise FileNotFoundError(label+' has no preserved launch record')
            print('Retaining existing '+label+'; final archive gate remains required',flush=True)
            return
        command=['powershell','-NoProfile','-ExecutionPolicy','Bypass','-File','assets/validation_5422/run_native.ps1',
                 '-Directory',args.directory,'-Label',label,'-Script',script or label+'.cfg','-Map',map_name]
        if load: command+=['-LoadGame',load]
        print('Running '+label,flush=True)
        result=subprocess.run(command,cwd=ROOT)
        files={}
        for save in sorted(folder.glob('*.zds')):
            with zipfile.ZipFile(save) as package:info=json.loads(package.read('info.json'))
            files[save.name]={'sha256':hashlib.sha256(save.read_bytes()).hexdigest(),'map':info['Current Map']}
        records.append({'label':label,'exit':result.returncode,'saves':files})
        path.write_text(json.dumps(records,indent=2)+'\n',encoding='utf-8')
        if result.returncode:raise RuntimeError(f'Failed: {label}; retained native log')
    if args.campaign:
        run('campaign',map_name='MAP02')
        run('port-reload',load='campaign-port.zds')
        run('port-roundtrip',load='campaign-port.zds')
        return
    if not args.saves_only:
        for i in range(args.start_kind,4):run(f'kind{i}')
        run('route')
        run('corridor',map_name='MAP97')
        run('resume',map_name='MAP97')
        run('edges',map_name='MAP97')
        run('stairs',map_name='MAP96')
        run('platform',map_name='MAP95')
        run('budget')
        run('combat')
    run('snapshot')
    run('load-current','savedcheck.cfg',load='escort-four.zds')
    run('hub',load='escort-four.zds')
    run('ongoing')
    run('load-ongoing','savedcheck.cfg',load='escort-ongoing.zds')
    run('blocked-save',map_name='MAP97')
    run('load-blocked','savedcheck.cfg',load='escort-blocked.zds')
    if args.legacy_save:
        destination=folder/'escort-legacy.zds'
        if destination.exists():raise FileExistsError(destination)
        shutil.copyfile(args.legacy_save,destination)
        run('load-legacy','savedcheck.cfg',load=destination.name)

if __name__=='__main__':main()

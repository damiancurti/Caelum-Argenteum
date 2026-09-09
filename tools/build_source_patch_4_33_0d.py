#!/usr/bin/env python3
"""Build only the source/assets/docs changed since V4.33.0c."""
import argparse
import hashlib
import subprocess
import sys
import zipfile
from pathlib import Path
import audit_4_33_0d as audit

def main():
    p=argparse.ArgumentParser();p.add_argument('--project-root',type=Path,required=True)
    p.add_argument('--baseline-0c-runtime',type=Path,required=True);p.add_argument('--full-runtime',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True);args=p.parse_args()
    root=args.project_root.resolve()
    command=[sys.executable,str(root/'tools/audit_4_33_0d.py'),
        '--project-root',str(root),'--baseline-0c-runtime',str(args.baseline_0c_runtime.resolve()),
        '--full-runtime',str(args.full_runtime.resolve())]
    subprocess.run(command,check=True)
    args.output.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(args.output,'w') as z:
        for name in sorted(audit.package_files(root)):
            info=zipfile.ZipInfo(name,audit.ZIP_TIME);info.create_system=3;info.external_attr=0o100644<<16
            z.writestr(info,(root/name).read_bytes(),compress_type=zipfile.ZIP_DEFLATED,compresslevel=9)
    subprocess.run(command+['--package',str(args.output.resolve())],check=True)
    print(args.output.resolve())
    print('SHA256:',hashlib.sha256(args.output.read_bytes()).hexdigest())
    print('Files:',len(audit.package_files(root)),'Bytes:',args.output.stat().st_size)

if __name__=='__main__':main()

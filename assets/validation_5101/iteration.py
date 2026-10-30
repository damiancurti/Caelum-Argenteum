"""Package changed included lumps for fast native iteration; no root ZSCRIPT."""
from pathlib import Path
import subprocess
import zipfile
ROOT=Path(__file__).resolve().parents[2]
files=subprocess.check_output(["git","-c","core.autocrlf=false","diff","--name-only","--","src"],cwd=ROOT,text=True).splitlines()
files+=subprocess.check_output(["git","ls-files","--others","--exclude-standard","src"],cwd=ROOT,text=True).splitlines()
with zipfile.ZipFile(ROOT/"build/issue426/current/iteration.pk3","w",zipfile.ZIP_STORED) as z:
    for name in sorted(set(files)):
        if name!="src/ZSCRIPT":
            z.writestr(zipfile.ZipInfo(name[4:],(2000,1,1,0,0,0)),(ROOT/name).read_bytes())
print("Updated iteration overlay; final evidence must use the full package.")

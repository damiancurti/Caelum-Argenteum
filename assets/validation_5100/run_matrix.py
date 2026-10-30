"""Run sequential native save/migration checks against the complete package."""
from pathlib import Path
import subprocess
import sys
HERE=Path(__file__).resolve().parent
scenarios=[
 ["release-save","--full","--commands","netevent ca425_seed; wait 36; save ca425-release-mid; wait 200"],
 ["release-reload","--full","--load","ca425-release-mid.zds","--commands","netevent ca425_reload; wait 180"],
 ["release-migration","--full","--load","ca425-legacy-final.zds","--commands","netevent ca425_legacy; wait 5"],
 ["release-rollback","--legacy","--load","ca425-legacy-final.zds","--commands","netevent ca425_verify; netevent ca425_done"],
]
for args in scenarios:
    subprocess.run([sys.executable,"-X","utf8",str(HERE/"run_native.py"),*args],check=True)

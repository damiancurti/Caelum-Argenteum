"""Full-package communication, save, rollback and help integration evidence."""
from pathlib import Path
import subprocess
import sys
ROOT=Path(__file__).resolve().parents[2]
RUNNER=Path(__file__).with_name('run_native.py')
cases=[
    ['legacy-seed','--legacy','--commands','netevent ca428_legacy; wait 2; save ca428-legacy; wait 2'],
    ['release-save','--full','--commands','netevent ca428_seed; wait 320; save ca428-final; wait 840'],
    ['release-reload','--full','--load','ca428-final.zds','--commands','netevent ca428_reload; wait 900'],
    ['release-migration','--full','--load','ca428-legacy.zds','--commands','netevent ca428_migration; wait 2'],
    ['release-rollback','--legacy','--load','ca428-legacy.zds','--commands','netevent ca428_rollback; wait 2'],
    ['release-help','--full','--commands','netevent ca428_help; wait 2'],
    ['release-auto','--full','--commands','netevent ca428_auto; wait 155'],
]
for args in cases:
    if "--full" in args:args += ["--package", "build/issue428/final/caelum_argenteum_dev.pk3"]
    subprocess.run([sys.executable,str(RUNNER),*args],cwd=ROOT,check=True)

"""Exercise the immutable full package, saved evidence, migration and rollback."""
from pathlib import Path
import subprocess
import sys
ROOT = Path(__file__).resolve().parents[2]
RUNNER = Path(__file__).with_name("run_native.py")
cases = [
    ["release-save", "--full", "--commands", "netevent ca426_seed; wait 90; save ca426-release; wait 5"],
    ["release-reload", "--full", "--load", "ca426-release.zds", "--commands", "netevent ca426_reload; wait 2"],
    ["release-migration", "--full", "--load", "ca426-legacy.zds", "--commands", "netevent ca426_migration; wait 2"],
    ["release-rollback", "--legacy", "--load", "ca426-legacy.zds", "--commands", "netevent ca426_rollback; wait 2"],
]
for args in cases:
    subprocess.run([sys.executable, str(RUNNER), *args], cwd=ROOT, check=True)

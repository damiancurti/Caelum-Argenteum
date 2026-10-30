"""Exercise active-time expiry, saved search, collision and reversible migration."""
from pathlib import Path
import subprocess
import sys
ROOT = Path(__file__).resolve().parents[2]
RUNNER = Path(__file__).with_name("run_native.py")
cases = [
    ["final-save", "--full", "--commands", "netevent ca427_seed; wait 200; save ca427-final; wait 1120"],
    ["final-reload", "--full", "--load", "ca427-final.zds", "--commands", "netevent ca427_reload; wait 1120"],
    ["final-migration", "--full", "--load", "ca427-legacy.zds", "--commands", "netevent ca427_migration; wait 2"],
    ["final-rollback", "--legacy", "--load", "ca427-legacy.zds", "--commands", "netevent ca427_rollback; wait 2"],
    ["final-wall", "--full", "--commands", "netevent ca427_wall; wait 115"],
]
for args in cases:
    subprocess.run([sys.executable, str(RUNNER), *args], cwd=ROOT, check=True)

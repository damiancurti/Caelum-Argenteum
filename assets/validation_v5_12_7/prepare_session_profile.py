"""Extend the existing #431 diagnostic scopes with cooperative services.

Only an isolated overlay is produced. Method bodies and production files are
preserved; the original profiler owns the sampling window and nested timing.
"""
from pathlib import Path
import importlib.util
import sys
import argparse
import hashlib
import json
import zipfile

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location(
    'original_profile', ROOT / 'assets/validation_v5_11_0/prepare_profile.py')
profile = importlib.util.module_from_spec(spec)
spec.loader.exec_module(profile)
SESSION_SPECS = {
    'world/CaelumWorldClock.zs': [
        ('override void WorldTick()', '', 'SharedWorldClock'),
        ('static void Mirror(CaelumPlayer source)', 'source', 'ClockMirror')],
    'world/CaelumSessionLifecycle.zs': [
        ('override void WorldTick()', '', 'SessionLifecycle')],
    'world/CaelumNarrativeCheckpoint.zs': [
        ('static void Observe(CaelumPlayer user)', 'user', 'NarrativeCheckpoint')],
    'player/CaelumPlayer.zs': [
        ('void PersistCharacterState()', '', 'ProfilePersistence')],
}
if __name__ == '__main__':
    if '--timers' not in sys.argv:
        raise SystemExit('This diagnostic requires --timers.')
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument('--baseline-runtime', type=Path)
    selected, remaining = parser.parse_known_args()
    if selected.baseline_runtime:
        package = selected.baseline_runtime.resolve(strict=True)
        digest = hashlib.sha256(package.read_bytes()).hexdigest()
        staging = ROOT / 'build/issue435/profile-baselines' / digest
        staging.mkdir(parents=True, exist_ok=True)
        with zipfile.ZipFile(package) as archive:
            names = {name.lower(): name for name in archive.namelist()}
            for relative in profile.SPECS:
                name = 'caelum/' + relative
                data = archive.read(names[name.lower()])
                destination = staging / 'src' / name
                destination.parent.mkdir(parents=True, exist_ok=True)
                if destination.exists() and destination.read_bytes() != data:
                    raise SystemExit('Refusing to replace a different retained source.')
                if not destination.exists():
                    destination.write_bytes(data)
        provenance = staging / 'source.json'
        if not provenance.exists():
            provenance.write_text(json.dumps(dict(path=str(package), sha256=digest), indent=2)+'\n')
        profile.ROOT = staging
        sys.argv = [sys.argv[0], *remaining]
    else:
        profile.SPECS.update(SESSION_SPECS)
    profile.main()

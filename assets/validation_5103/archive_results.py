"""Normalize selected final evidence without deleting local diagnostic attempts."""
from pathlib import Path
import hashlib
import json
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue428'


def preserve(source, target):
    text = source.read_text(encoding='utf-8-sig')
    target.write_bytes(('\n'.join(line.rstrip() for line in text.splitlines()) + '\n').encode('utf-8'))


def main():
    labels = ['legacy-seed', 'release-save', 'release-reload', 'release-migration',
              'release-rollback', 'release-help', 'release-auto',
              'integrated-425-memory', 'integrated-426', 'integrated-427-expiry']
    runs = []
    for label in labels:
        data = json.loads((OUT / (label + '.json')).read_bytes())
        if data['exit_code'] or data['failures'] or data['pass_count'] == 0:
            raise SystemExit(f'Unresolved evidence: {label}')
        for suffix in ('.json', '.log'):
            preserve(OUT / (label + suffix), HERE / (label + suffix))
        runs.append(dict(run=label, passes=data['pass_count'], elapsed_seconds=data['elapsed_seconds']))
    performance = {}
    for scene in ('mansion', 'sewers', 'city', 'ground', 'siege'):
        performance[scene] = {}
        for version in ('baseline', 'final'):
            label = version + '-' + scene
            data = json.loads((OUT / 'performance' / (label + '.json')).read_bytes())
            if data['exit_code'] or data['simulation'] is None or data['render_callbacks'] is None:
                raise SystemExit(f'Unresolved performance evidence: {label}')
            for suffix in ('.json', '.log'):
                preserve(OUT / 'performance' / (label + suffix), HERE / (label + suffix))
            performance[scene][version] = {key: data[key] for key in ('simulation', 'render_callbacks', 'census')}
    package = OUT / 'final/caelum_argenteum_dev.pk3'
    changed = subprocess.check_output(['git', 'diff', '--name-only', 'HEAD', '--', 'src'], cwd=ROOT, text=True).splitlines()
    changed += ['src/caelum/actors/CaelumCommunication.zs', 'src/caelum/data/CaelumCommunicationData.zs']
    with zipfile.ZipFile(package) as archive:
        for file in changed:
            if archive.read(file[4:]) != (ROOT / file).read_bytes():
                raise SystemExit(f'Runtime changed after tested full package: {file}')
    summary = dict(issue=428, version='5.10.3', date='2026-10-30', runs=runs,
        communication_assertions=sum(row['passes'] for row in runs[1:7]),
        combined_regression_assertions=sum(row['passes'] for row in runs[7:]),
        full_package_sha256=hashlib.sha256(package.read_bytes()).hexdigest(),
        verified_runtime_files=len(changed), performance=performance,
        integration_adjustments=[
            'The historical #425 scenario reused an identity learned three seconds earlier. The adapted fixture verifies immediate known-person reacquisition and separately spawns a genuinely unknown body; historical evidence stays unchanged.',
            'The first #427 integration run ended before its expiry checks. The corrected run preserves the original 1320-tic observation window.'
        ],
        limits=[
            'Author corroboration remains pending; no V5.10 issue is closed or merged.',
            'RenderOverlay callback intervals are not monitor presentation FPS. ETW was unavailable in the prior environment and no PresentMon executable is currently installed in the expected local tool path.',
            'The 1000-attacker/600-defender campaign reference is already slow on the accepted 5.9.7 baseline; frame tails and actual populations are reported, without a 60-FPS claim.',
            'The Windows computer-use bridge was unavailable. Visual review used native GZDoom screenshot commands and inspected images; this does not establish physical keyboard delivery.'
        ],
        log_normalization='UTF-8, LF, trailing whitespace removed; original and failed/diagnostic attempts retained in local build/issue428.')
    (HERE / 'summary.json').write_bytes((json.dumps(summary, indent=2) + '\n').encode())
    print(json.dumps({key: summary[key] for key in ('communication_assertions', 'combined_regression_assertions', 'full_package_sha256', 'verified_runtime_files')}, indent=2))


if __name__ == '__main__':
    main()

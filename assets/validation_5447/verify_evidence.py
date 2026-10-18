"""Verify archived text evidence and exact tested-source/normal-package equality."""
from pathlib import Path
import hashlib
import json
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent


def digest(data):
    return hashlib.sha256(data).hexdigest()


def main():
    evidence = json.loads((HERE/'npc_evidence.json').read_text(encoding='utf-8'))
    archive_path = HERE/'npc_evidence.zip'
    assert digest(archive_path.read_bytes()) == evidence['archive_sha256']
    with zipfile.ZipFile(archive_path) as archive:
        assert set(archive.namelist()) == set(evidence['members'])
        for name, expected in evidence['members'].items():
            assert digest(archive.read(name)) == expected, name
        manifest = json.loads(archive.read('issue361-npc-checks/manifest.json'))
    sources = {p.relative_to(ROOT/'src').as_posix(): digest(p.read_bytes())
               for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert sources == manifest['source_hashes'], 'Normal sources differ from final tested runtime'
    restored = ['caelum/player/CaelumPlayer.zs', 'caelum/player/CaelumPlayerResources.zs',
                'caelum/world/CaelumSiegeEncounter.zs']
    for name in restored:
        original = subprocess.check_output(['git', 'show', 'f3fedf95:src/'+name], cwd=ROOT)
        assert (ROOT/'src'/name).read_bytes().replace(b'\r\n', b'\n') == original.replace(b'\r\n', b'\n'), name
    package_path = ROOT/'build/caelum_argenteum_dev.pk3'
    with zipfile.ZipFile(package_path) as package:
        assert set(package.namelist()) == set(sources), 'Unexpected package members'
        for name, expected in sources.items():
            assert digest(package.read(name)) == expected, name
        assert not any(name.endswith('probe.zs') or 'ca361' in name.lower() for name in package.namelist())
    expected_seeds = {
        'auto00.zds': '20d00394f1da5039aeb2bc982e6f10a9197435e2dacd83fbdfda40faf62c9a84',
        'auto03.zds': '96631010f735e3d3466c6e0de162afe2dad2c81f4e7b0977035025656653dba8',
    }
    for name, expected in expected_seeds.items():
        assert digest((ROOT/'build/issue354-preview01'/name).read_bytes()) == expected, name
    report = dict(issue=361, release='5.4.47', package_sha256=digest(package_path.read_bytes()),
                  package_members=len(sources), exact_tested_source_equality=True,
                  probes_in_normal_package=False, original_private_saves_unchanged=True,
                  evidence_members_verified=len(evidence['members']),
                  final_native_runs=evidence['successful_final_runs'],
                  final_native_assertions=evidence['successful_final_assertions'],
                  player_and_event_sources_restored_to='f3fedf95', restored_files=restored)
    (HERE/'npc_delivery_checks.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
    print(json.dumps(report))


if __name__ == '__main__':
    main()

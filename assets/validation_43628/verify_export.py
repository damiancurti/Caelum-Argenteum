"""Independently verify #17 archive hashes and exact committed runtime content."""
import argparse
import hashlib
import io
import json
from pathlib import Path
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]


def sha(data):
    return hashlib.sha256(data).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('archive', type=Path)
    args = parser.parse_args()
    data = args.archive.read_bytes()
    expected = Path(str(args.archive) + '.sha256').read_text().split()[0]
    assert sha(data) == expected, 'Outer ZIP checksum mismatch'
    with zipfile.ZipFile(io.BytesIO(data)) as bundle:
        assert bundle.testzip() is None, 'ZIP CRC failure'
        names = bundle.namelist()
        assert len(names) == len(set(names)), 'Duplicate delivery member'
        sums = {}
        for line in bundle.read('SHA256SUMS.txt').decode().splitlines():
            checksum, name = line.split('  ', 1)
            assert checksum == sha(bundle.read(name)), name
            sums[name] = checksum
        assert set(sums) == set(names) - {'SHA256SUMS.txt'}, 'Checksum coverage gap'
        manifest = json.loads(bundle.read('MANIFEST.json'))
        commit = manifest['source_commit']
        tree = subprocess.check_output(['git', '-C', str(ROOT), 'ls-tree', '-r', '-z', commit, 'src']).decode()
        expected_blobs = {}
        for entry in tree.rstrip('\0').split('\0'):
            attributes, path = entry.split('\t')
            mode, kind, oid = attributes.split()
            assert mode == '100644' and kind == 'blob', path
            expected_blobs[path[4:]] = oid
        package_bytes = bundle.read(manifest['package'])
        assert sha(package_bytes) == manifest['package_sha256']
        with zipfile.ZipFile(io.BytesIO(package_bytes)) as package:
            assert package.testzip() is None
            runtime_names = package.namelist()
            assert len(runtime_names) == len(set(runtime_names))
            assert set(runtime_names) == set(expected_blobs), 'Runtime differs from committed inventory'
            records = {record['path']: record for record in manifest['runtime_files']}
            assert set(records) == set(runtime_names)
            for name in runtime_names:
                content = package.read(name)
                blob = b'blob ' + str(len(content)).encode() + b'\0' + content
                assert hashlib.sha1(blob).hexdigest() == expected_blobs[name], name
                assert sha(content) == records[name]['sha256'] and len(content) == records[name]['size'], name
            licenses = {name for name in runtime_names if name.startswith('licenses/')}
            allowed = {'caelum_argenteum_dev.pk3','PLAYTEST.txt','LICENSE.md','MANIFEST.json',
                       'launch_playtest.ps1','launch_playtest.bat','SHA256SUMS.txt'} | licenses
            assert set(names) == allowed, 'Unreviewed delivery file'
            for name in licenses:
                assert bundle.read(name) == package.read(name), name
            for archive in (bundle, package):
                assert archive.namelist() == sorted(archive.namelist())
                for entry in archive.infolist():
                    assert entry.date_time == (1980,1,1,0,0,0)
                    assert entry.compress_type == zipfile.ZIP_STORED
                    assert not entry.is_dir() and entry.file_size > 0
    print(json.dumps({'result':'PASS', 'source_commit':commit, 'runtime_members':len(expected_blobs),
                      'zip_sha256':sha(data), 'pk3_sha256':sha(package_bytes),
                      'scope':'Independent Git blob identity, complete hash coverage, CRC, allowlist, metadata and licenses'}, indent=2))


if __name__ == '__main__':
    main()

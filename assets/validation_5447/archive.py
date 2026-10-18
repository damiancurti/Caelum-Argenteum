"""Archive only text evidence; never include engines, IWADs, saves or PK3 assets."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
FOLDERS = ['issue361-checks01', 'issue361-checks02', 'issue361-checks03',
           'issue361-checks04', 'issue361-final-checks', 'issue361-live01',
           'issue361-live02', 'issue361-live03', 'issue361-rollback']
FINAL = [('issue361-final-checks', 'final-checks'), ('issue361-live03', 'old-city03'),
         ('issue361-live03', 'hub03'), ('issue361-live03', 'old-house03'),
         ('issue361-live03', 'new-house03'), ('issue361-rollback', 'rollback01')]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--npc-only', action='store_true')
    args = parser.parse_args()
    folders = ['issue361-npc-checks', 'issue361-npc-live', 'issue361-npc-live02', 'issue361-npc-hub-final'] if args.npc_only else FOLDERS
    final = ([('issue361-npc-checks', 'npc-checks'), ('issue361-npc-hub-final', 'npc-hub-final')]+[
        ('issue361-npc-live02', label) for label in
        ['npc-old-city', 'npc-prior-city', 'npc-prior-house', 'npc-current-house']]
        if args.npc_only else FINAL)
    prefix = 'npc_' if args.npc_only else ''
    members = {}
    results = []
    for folder in folders:
        path = ROOT/'build'/folder
        for pattern in ['*.json', '*.txt', '*.cfg']:
            for item in path.glob(pattern):
                members[folder+'/'+item.name] = item.read_bytes()
        with zipfile.ZipFile(path/'city.pk3') as fixture:
            for name in ['probe.zs', 'MAPINFO', 'ZSCRIPT']:
                members[folder+'/fixture/'+name] = fixture.read(name)
    for folder, label in final:
        log = (ROOT/'build'/folder/(label+'.txt')).read_text(encoding='utf-8-sig')
        record = json.loads((ROOT/'build'/folder/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        matches = re.findall(r'CA282 DONE passes=(\d+) failures=(\d+)', log)
        assert matches and not re.search(r'CA282 FAIL|VM execution aborted|Script error', log)
        assert all(int(failures) == 0 for _, failures in matches) and record['exit_code'] == 0
        if label == 'npc-hub-final':
            assert 'CA361 PROGRESS checkpoints=3' in log
            assert 'CA361 LIVE map=CAH008' in log and log.rfind('CA361 LIVE map=MAP03') > log.rfind('CA361 LIVE map=CAH008')
        results.append(dict(folder=folder, label=label, checks=int(matches[-1][0]),
                            runtime_sha256=record['runtime_sha256'].lower()))
    with zipfile.ZipFile(HERE/(prefix+'evidence.zip'), 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for name, data in sorted(members.items()):
            info = zipfile.ZipInfo(name, (1980, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            archive.writestr(info, data)
    report = dict(issue=361, release='5.4.47', successful_final_runs=len(results),
                  successful_final_assertions=sum(row['checks'] for row in results),
                  results=results, text_members=len(members),
                  archive_sha256=hashlib.sha256((HERE/(prefix+'evidence.zip')).read_bytes()).hexdigest(),
                  members={name: hashlib.sha256(data).hexdigest() for name, data in sorted(members.items())})
    (HERE/(prefix+'evidence.json')).write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
    print(json.dumps({k: v for k, v in report.items() if k != 'members'}))


if __name__ == '__main__':
    main()

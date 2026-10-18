"""Archive only text evidence from the enumerated private native runs."""
from pathlib import Path
import hashlib,json,re,zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
FINAL=[('issue334-final-'+label+'04',label) for label in
    ['controls','pending','arrival','interrupt','newgame','ship','cart','ship-house','cart-house']]
FINAL += [('issue334-final-roundtrip04','roundtrip'),
    ('issue334-final-roundtrip-cap05','roundtrip'),('issue334-source-player02','source'),
    ('issue334-final-reload05','reload')]
DRAFT=['issue334-native01','issue334-native02']+['issue334-melt'+str(i).zfill(2) for i in range(1,6)]
DRAFT += ['issue334-source01','issue334-final-arrival01','issue334-final-arrival02','issue334-final-arrival03',
    'issue334-final-newgame03']
def digest(data):return hashlib.sha256(data).hexdigest()
def main():
    members={};runs=[]
    for folder,label in FINAL:
        work=ROOT/'build'/folder
        run=json.loads((work/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        log=(work/(label+'.txt')).read_text(encoding='utf-8')
        matches=re.findall(r'CA282 DONE passes=(\d+) failures=(\d+)',log)
        assert run['exit_code']==0 and matches and all(f=='0' for _,f in matches),folder
        if label=='reload':
            # The static observer reports a cumulative 4 -> 8 before a separate
            # one-assertion final travel gate. Do not count the first four twice.
            assert matches==[('4','0'),('8','0'),('1','0')]
            count=9
        else:count=sum(int(p) for p,_ in matches)
        runs.append(dict(folder=folder,label=label,assertions=count))
    for folder in dict.fromkeys([f for f,_ in FINAL]+DRAFT):
        work=ROOT/'build'/folder
        assert work.is_dir(),folder
        for path in sorted(work.iterdir()):
            # Intentionally exclude game packages, saves, images and user INIs.
            # That interactive draft embeds a personal INI in its run record;
            # its log/manifest/commands suffice to disclose the failed attempt.
            if folder=='issue334-melt03' and path.name.endswith('-run.json'):continue
            if path.is_file() and path.suffix in ['.txt','.cfg','.json']:
                members[folder+'/'+path.name]=path.read_bytes()
    visual={}
    for name in ['before.png','source.png','held-arrival.png','destination.png']:
        visual[name]=digest((ROOT/'build/issue334-source-player02'/name).read_bytes())
    with zipfile.ZipFile(HERE/'evidence.zip','w',zipfile.ZIP_DEFLATED) as archive:
        for name,data in sorted(members.items()):
            info=zipfile.ZipInfo(name,(2000,1,1,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED
            archive.writestr(info,data)
    record=dict(issue=334,release='5.4.46',successful_runs=runs,
        native_assertions=sum(r['assertions'] for r in runs),
        private_native_screenshot_sha256=visual,
        sha256={name:digest(data) for name,data in sorted(members.items())})
    (HERE/'evidence.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8')
    print(f'Archived {len(members)} text members; {len(runs)} final runs, {record["native_assertions"]} assertions.')
if __name__=='__main__':main()

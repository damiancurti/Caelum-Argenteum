"""Retain scoped native evidence without packaging configs, saves or binaries."""
from pathlib import Path
import hashlib,json,re,shutil,zipfile
ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'build/issue209';HERE=Path(__file__).resolve().parent
def sha(data):return hashlib.sha256(data).hexdigest()
def main():
    (HERE/'logs').mkdir(exist_ok=True);runs=[]
    for p in sorted(WORK.glob('*-run.json')):
        entry=json.loads(p.read_text(encoding='utf-8-sig'));name=entry['label'];log=WORK/(name+'.txt')
        if log.exists():
            raw=log.read_bytes();text=raw.decode('utf-8',errors='replace').replace('\r\n','\n')
            text=text.replace(str(ROOT),'<PROJECT>')
            text=re.sub(r'C:[/\\]Program Files \(x86\)[/\\]GZDoom','<ENGINE>',text,flags=re.I)
            text=re.sub(r'C:[/\\]Program Files \(x86\)[/\\]Steam[^\r\n]*?DOOM2\.WAD','<DEVELOPMENT_IWAD>',text,flags=re.I)
            text=re.sub(r'C:[/\\]Users[/\\][^/\\\r\n]+','<USER>',text,flags=re.I)
            text='\n'.join(line.rstrip() for line in text.split('\n'))
            retained=text.encode();(HERE/'logs'/log.name).write_bytes(retained)
            entry.update(raw_log_sha256=sha(raw),retained_log_sha256=sha(retained),completion=re.findall(r'CA209 DONE[^\r\n]*',text),assertion_failures=len(re.findall(r'CA209 FAIL',text)))
        if entry.get('loadgame'):entry['loadgame']=Path(entry['loadgame']).name
        runs.append(entry)
    (HERE/'runs.json').write_text(json.dumps(runs,indent=2)+'\n',encoding='utf-8',newline='\n')
    check={}
    with zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as official,zipfile.ZipFile(WORK/'production.pk3') as tested:
        a={n:sha(official.read(n)) for n in official.namelist()};b={n:sha(tested.read(n)) for n in tested.namelist()}
        assert a==b,'Official build differs from tested production package'
        check={'members':len(a),'official_matches_tested_members':True,'official_sha256':sha((ROOT/'build/caelum_argenteum_dev.pk3').read_bytes()),'tested_sha256':sha((WORK/'production.pk3').read_bytes()),'fixture_sha256':sha((WORK/'fixture.pk3').read_bytes())}
    (HERE/'package-checks.json').write_text(json.dumps(check,indent=2)+'\n',encoding='utf-8',newline='\n')
    awake=WORK/'keep-awake.json'
    if awake.exists():shutil.copy2(awake,HERE/'keep-awake.json')
    shots=['movement-final.png','fall-rest-final.png','baseline-chair.png','baseline-front.png','chair-side.png','canteen-front.png','canteen-side.png','canteen-back.png','bag-side.png','female-sword.png','female-sword-attack.png','female-shield.png','female-shotgun.png','female-shotgun-gloves.png']
    shots += [f'actual-hands-{i}.png' for i in [0,18,21,24,36]]
    shots += [f'bed-{s}-{v}.png' for s in range(2) for v in [0,2,4,6]]
    shots += [f'corpse-{r}-{s}.png' for r in [1,2,3] for s in range(2)]
    shots += [f'face-{r}-{s}.png' for r in [1,2,3] for s in range(2)]
    (HERE/'captures').mkdir(exist_ok=True)
    for name in shots:
        retained='fall-rest-before-rear-adjustment.png' if name=='fall-rest-final.png' else name
        shutil.copy2(WORK/name,HERE/'captures'/retained)
    (HERE/'interactive.json').write_text(json.dumps({'run':'live-input-01','tool':'computer-use @oai/sky','agent_observed':['F: food ON, rest remained active','G: water ON, rest remained active','Eat click: food OFF, rest remained active','Q: rest ended, first-person returned'],'author_acceptance':False,'profile_ini_untouched':True},indent=2)+'\n',encoding='utf-8',newline='\n')
    print(f'Exported {len(runs)} native runs, {len(shots)} captures; official package matches {len(a)} tested members.')
if __name__=='__main__':main()

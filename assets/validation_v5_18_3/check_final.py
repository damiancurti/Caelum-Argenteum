"""Check delivery identity, preserved author scope and affected tool contracts."""
from pathlib import Path
import ast,hashlib,json,re,subprocess,sys,zipfile

ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT))
import build_release,build_document_index

def sha(path):
    with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()

def main():
    release=ROOT/'build/CaelumArgenteum-5.18.3-prologue-review03'
    archive=release.parent/(release.name+'.zip')
    repeated=ROOT/'build/CaelumArgenteum-5.18.3-repeat02.zip'
    assert sha(archive)==sha(repeated)
    for name in build_release.SUPPORT_FILES:assert sha(ROOT/name)==sha(release/name),name
    readme=(ROOT/'README.md').read_text(encoding='utf8')
    guide=readme.split('<!-- independent-player-guide:start -->')[1].split('<!-- independent-player-guide:end -->')[0].strip()+'\n'
    assert (release/'PLAYER_GUIDE.txt').read_text(encoding='utf8')==guide
    build_release.check_support_imports()
    original=build_release.SUPPORT_FILES[:]
    try:
        build_release.SUPPORT_FILES.remove('migrate_arena_save.py')
        try:build_release.check_support_imports()
        except ValueError as error:assert 'migrate_arena_save.py' in str(error)
        else:raise AssertionError('Omitted transitive import was accepted')
    finally:build_release.SUPPORT_FILES[:]=original
    for action in [lambda:build_release.build(None,release),lambda:build_release.archive_release(release)]:
        try:action()
        except ValueError:pass
        else:raise AssertionError('Existing delivery overwrite was accepted')
    prior=subprocess.check_output(['git','show','c64858420d485872683cf991b9d7b94c1f4d2c9d:pending_test.txt'],cwd=ROOT).decode('utf8')
    pending=(ROOT/'pending_test.txt').read_text(encoding='utf8')
    assert pending.startswith(prior.rstrip()+'\n')
    ids=re.findall(r'^(CA\S+) \| Origin',pending,re.M);assert len(ids)==115 and len(set(ids))==115
    files=['AGENTS.md']+['docs/'+n for n in ['ASSETS.md','CONTEXT.md','HISTORY.md','MAP01.txt','PROJECT.md','SPRITE_ART_DIRECTION.md','SYSTEMS.md','TASKS.md']]
    for name in files:
        assert re.search(r'Documentation version:\s*\*?\*?5\.18\.3\b',(ROOT/name).read_text(encoding='utf8')[:1000]),name
    assert re.search(r'Current release:\s*5\.18\.3\b',readme)
    assert (ROOT/'docs/DOCUMENT_INDEX.md').read_text(encoding='utf8')==build_document_index.build_index(ROOT)+'\n'
    changes=[]
    with zipfile.ZipFile(ROOT/'build/issue468-review01/caelum_argenteum.ipk3') as old,zipfile.ZipFile(release/'caelum_argenteum.ipk3') as new:
        assert old.namelist()==new.namelist()
        for name in old.namelist():
            before,after=old.read(name),new.read(name)
            if before!=after:
                assert before.replace(b'5.18.2',b'5.18.3')==after,name;changes.append(name)
    assert sorted(changes)==['caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs']
    sources=['build_release.py','caelum_standalone.py']
    sources += ['assets/validation_v5_17_123/'+n for n in ['sessions.py','author_terminal.py','check_catalog.py']]
    sources += [p.relative_to(ROOT).as_posix() for p in (ROOT/'assets/validation_v5_18_3').glob('*.py')]
    for name in sources:ast.parse((ROOT/name).read_text(encoding='utf8'))
    composition=[]
    for part in ['components','ceilings','municipal','waterline']:
        for path in (ROOT/'build/issue469-compositions01'/part).glob('*.pk3'):
            assert sha(path)==sha(ROOT/'build/issue889-release02'/part/path.name)
            composition.append(dict(path=part+'/'+path.name,sha256=sha(path)))
    cat=json.loads((ROOT/'assets/validation_v5_18_3/CATALOG.json').read_text(encoding='utf8'))
    first=json.loads((ROOT/'build/author-889/issue469-catalog01/RESULTS.json').read_text())
    retry=json.loads((ROOT/'build/author-889/issue469-catalog02/RESULTS.json').read_text())
    rows={r['action']:r for r in first['rows']};rows.update({r['action']:r for r in retry['rows']})
    assert all(r['passed'] for r in rows.values()) and set(rows)=={a['id'] for a in cat['actions'] if a['kind'] not in ['gallery','tool']}
    report=dict(issue=469,passed=True,version='5.18.3',archive_sha256=sha(archive),runtime_sha256=sha(release/'caelum_argenteum.ipk3'),
        deterministic_repeat=True,preserved_previous_checks=114,pending_checks=115,catalog_actions=len(cat['actions']),prepared_native_actions=len(rows),
        omitted_import_refused=True,existing_directory_and_zip_preserved=True,source_guide_and_support_files_match=True,
        runtime_equivalence_except_version_labels=changes,identical_review_compositions=composition,
        source_sha256={n:sha(ROOT/n) for n in sources},author_acceptance=False)
    out=ROOT/'build/issue469-final-static.json';out.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k not in ['source_sha256','identical_review_compositions']}))

if __name__=='__main__':main()

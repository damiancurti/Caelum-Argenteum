"""Historical pre-sweat binding at df49f40b; current work uses record_sweat_manifest.py."""
from pathlib import Path
import hashlib
import json
import shutil
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue133'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    package=WORK/'production.pk3'
    names={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    for target in (package,ROOT/'build/caelum_argenteum_dev.pk3',WORK/'upgrade/baseline.pk3'):
        with zipfile.ZipFile(target) as archive:
            assert set(names)==set(archive.namelist()), f'Runtime/package file set differs: {target}'
            for name,path in names.items():
                if target==WORK/'upgrade/baseline.pk3' and name=='maps/MAP06.wad':
                    path=ROOT/'assets/map06_port/legacy_512/MAP06.wad'
                assert archive.read(name)==path.read_bytes(),f'Runtime/package content differs: {target} / {name}'
    final_sha=sha(package)
    changed=subprocess.check_output(['git','diff','--name-only','b00201098a26582c8820a5424a2a75986b022abf','--','src'],cwd=ROOT,text=True).splitlines()
    added=subprocess.check_output(['git','ls-files','--others','--exclude-standard','src'],cwd=ROOT,text=True).splitlines()
    sources={name:sha(ROOT/name) for name in sorted(set(changed+added)) if (ROOT/name).is_file()}
    committed={}
    for name in sources:
        blob=subprocess.check_output(['git','show','f4c2bdfe:'+name],cwd=ROOT)
        current=(ROOT/name).read_bytes()
        same=blob==current
        assert same or (b'\0' not in blob and blob.replace(b'\r\n',b'\n')==current.replace(b'\r\n',b'\n')),name
        committed[name]={'git_blob_sha256':hashlib.sha256(blob).hexdigest(),
            'working_tree_equivalence':'exact' if same else 'CRLF/LF only'}
    records={}
    for path in sorted(HERE.glob('*-run.json')):
        record=json.loads(path.read_text(encoding='utf-8-sig'))
        if not record.get('completed_utc'):continue
        records[path.name]={'sha256':sha(path),'package_sha256':record['package_sha256'],
            'addon_sha256':record['addon_sha256'],'expected':record['expected'],
            'matches_final_production':record['package_sha256'].lower()==final_sha}
    shots={}
    visual_dir=HERE/'captures';visual_dir.mkdir(exist_ok=True)
    for path in sorted(WORK.glob('final-visual-*.png')):
        selected=('pose-0-' in path.name or any(s in path.name for s in (
            'pose-1-0','pose-2-0','pose-3-0','pose-3-2','pose-3-4','pose-3-6',
            'pose-4-0','pose-5-0','player-fire','player-crouch','player-sword',
            'shop-first','shop-last','shop-en','home')))
        if selected:shutil.copyfile(path,visual_dir/path.name)
        shots[path.name]={'sha256':sha(path),'retained':selected}
    assert len(shots)==60, f'Expected 60 native visual captures, got {len(shots)}'
    supplemental=WORK/'final-player-shot-player-single-shot.png'
    shutil.copyfile(supplemental,visual_dir/supplemental.name)
    shutil.copyfile(WORK/'final-visual-commands.json',HERE/'final-visual-commands.json')
    required=('route-delivery','final-checks','final-carbine','final-replacement',
        'final-deployment-save','final-deployment-reload','final-deployment-hub',
        'final-obstruction','delivery-trade','delivery-trade-reload','delivery-trade-hub',
        'delivery-furniture','delivery-factories','final-visual','final-player-shot',
        'manual-smoke','perf-city-staged','perf-volleys','volley-cause')
    for label in required:
        assert records[label+'-run.json']['matches_final_production'],label
    fixtures={}
    for name in ('checks','routes','trade','carbine','factories','visual','furniture','obstruction',
                 'legacy','deployment','manual','observer','combined','volleys','replacement/routes'):
        target=WORK/(name+'.pk3')
        with zipfile.ZipFile(target) as archive:
            for member in archive.namelist():
                if not member.endswith('.zs'):continue
                source=ROOT/'assets/validation_512/observer.zs' if member=='observer.zs' else HERE/member
                assert archive.read(member)==source.read_bytes(),f'Probe/source mismatch: {name} / {member}'
        fixtures[name+'.pk3']=sha(target)
    report={'issue':133,'version':'5.1.3','baseline_commit':'b00201098a26582c8820a5424a2a75986b022abf',
        'production_package_sha256':final_sha,'production_matches_current_src_byte_for_byte':True,
        'default_build_sha256':sha(ROOT/'build/caelum_argenteum_dev.pk3'),
        'compatible_build_sha256':sha(WORK/'upgrade/baseline.pk3'),
        'compatible_build_only_runtime_difference':'maps/MAP06.wad replaced with exact legacy_512 bytes',
        'changed_runtime_sources':sources,'completed_records':records,'native_visual_captures':shots,
        'implementation_commit':'f4c2bdfe','committed_runtime_binding':committed,
        'supplemental_single_shot_capture':{'name':supplemental.name,'sha256':sha(supplemental)},
        'verified_probe_packages':fixtures,
        'qualification':'Per-run package hashes identify earlier component builds. Final source reuse is explained in RESULTS.md; a completed exploratory counter is not an acceptance pass.'}
    (HERE/'MANIFEST.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(f'Bound {len(sources)} runtime sources, {len(records)} run records, {len(shots)} captures.')


if __name__=='__main__':main()

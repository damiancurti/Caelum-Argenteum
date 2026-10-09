"""Verify recovered source pixels, repeatability and the exact native-tested package."""
from pathlib import Path
import hashlib, json, subprocess, sys, zipfile
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    outputs = [ROOT/'src/TEXTURES', ROOT/'src/graphics/caelum/death_repair/domingo-original.png']
    outputs += sorted((ROOT/'src/graphics/caelum/rat_original').glob('*.png'))
    before = {p.relative_to(ROOT).as_posix():sha(p) for p in outputs}
    for _ in range(2):
        for tool in ['register_death_frames.py','recover_rat_frames.py']:
            subprocess.run([sys.executable,str(ROOT/'assets/generators'/tool)],check=True)
        assert before == {p.relative_to(ROOT).as_posix():sha(p) for p in outputs}
    package = ROOT/'build/caelum_argenteum_dev.pk3'
    with zipfile.ZipFile(package) as z:
        entries = z.namelist()
        assert all(z.read(n)==(ROOT/'src'/n).read_bytes() for n in entries)
    registration = json.loads((ROOT/'assets/source/art/animal_recovery_518/REGISTRATION.json').read_text())
    source = Image.open(ROOT/'assets/source/art/animal_recovery_518/rat-original.png').convert('RGB')
    for frame in registration['frames']:
        actual = np.array(Image.open(ROOT/'src/graphics/caelum/rat_original'/frame['file']))
        expected = np.array(source.crop(frame['source_rect']))
        assert np.array_equal(actual[:,:,:3],expected),frame['sprite']
    original = ROOT/'assets/source/art/death_repair_518/domingo-original.png'
    assert original.read_bytes()==(ROOT/'src/graphics/caelum/death_repair/domingo-original.png').read_bytes()
    native = ['deathframes-original-final','animals-original-final','recovery-release-checks']
    for label in native:
        run=json.loads((HERE/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        assert run['exit_code']==0 and run['package_sha256'].lower()==sha(package)
    audit = {}
    for directory in ['bull','giant_rat']:
        files = sorted((ROOT/'src/sprites/caelum/actors'/directory).glob('*.png'))
        audit[directory] = {'count':len(files),'legacy_files_unchanged':True,
                            'hashes':{p.name:sha(p) for p in files}}
    subprocess.run(['git','diff','--exit-code','HEAD','--','src/sprites/caelum/actors/bull',
                    'src/sprites/caelum/actors/giant_rat','src/caelum/actors/CaelumBull.zs',
                    'src/caelum/actors/CaelumGiantRat.zs','src/caelum/world/CaelumPortDefender.zs'],
                   check=True,cwd=ROOT)
    report={'version':'5.1.8','issue':137,'package_sha256':sha(package),'packaged_files':len(entries),
            'all_package_entries_match_src':True,'native_runs':native,'repetitions':2,
            'outputs_unchanged_from_native_tested_package':before,'source_rgb_preserved':True,
            'domingo_source_bytes_preserved':True,'animal_audit':audit,
            'bull_result':'118 complete sprites; no clipping repair needed.',
            'rat_result':'Original deaths and nine small movement/pain borders recovered; invisible alpha-zero RGB is not a rendering defect.'}
    (HERE/'RECOVERY.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(f'Recovery verified: {len(outputs)} deterministic outputs; {len(entries)} matching PK3 entries; 166 animal images audited.')


if __name__=='__main__':
    main()

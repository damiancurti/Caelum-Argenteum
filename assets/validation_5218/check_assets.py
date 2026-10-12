"""Verify current native resources and byte-for-byte generator determinism."""
from pathlib import Path
import argparse,hashlib,json,re,subprocess,sys
ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/appearance_5218'
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def outputs():
    paths=set()
    for name in ['REGISTRATION.json','DETAIL_REGISTRATION.json','HAND_REGISTRATION.json']:
        p=SOURCE/name;paths.add(p)
        for name,expected in json.loads(p.read_text())['module_sha256'].items():
            path=ROOT/name
            assert sha(path)==expected,('manifest mismatch',path)
            paths.add(path)
    for name in ['appearance.textures','appearance-details.textures','appearance-hands.textures']:
        path=ROOT/'src/graphics/caelum'/name;paths.add(path)
        for ref in re.findall(r'"([^"\n]+\.png)"',path.read_text()):assert (ROOT/'src'/ref).exists(),ref
    for name in ['CaelumAppearanceRegistry','CaelumAppearanceDetailsRegistry','CaelumAppearanceHandFrames']:
        paths.add(ROOT/f'src/caelum/character/{name}.zs')
    paths.add(ROOT/'src/models/caelum/props/rest/ca_large_canteen.obj')
    return {p.relative_to(ROOT).as_posix():sha(p) for p in sorted(paths)}
def main():
    parser=argparse.ArgumentParser();parser.add_argument('--repeat',action='store_true');args=parser.parse_args()
    before=outputs()
    text=(ROOT/'src/caelum/character/CaelumAppearanceHandFrames.zs').read_text()
    labels=re.findall(r'^    V(\d+)_(\w+):',text,re.M)
    assert len(labels)==1850 and len(set(labels))==1850
    assert all(sum(int(v)==n for v,_ in labels)==50 for n in range(37))
    mesh=(ROOT/'src/models/caelum/props/rest/ca_large_canteen.obj').read_text()
    assert all(len(line.split()) in (4,5) for line in mesh.splitlines() if line.startswith('f ')), 'OBJ n-gon'
    if args.repeat:
        for name in ['generate_modular_appearance','generate_appearance_details','generate_appearance_hands','generate_dining_canteen']:
            subprocess.run([sys.executable,str(ROOT/f'assets/generators/{name}.py')],check=True,cwd=ROOT)
        after=outputs();assert after==before,'Generator output changed on repeat'
    # Git normalizes maintained text to LF. Preserve the raw repeat comparison
    # above, but publish portable fingerprints for cloned checkouts.
    canonical={name:hashlib.sha256((ROOT/name).read_bytes().replace(b'\r\n',b'\n')).hexdigest()
               if Path(name).suffix in ('.json','.zs','.textures','.obj') else value
               for name,value in before.items()}
    result={'issue':209,'outputs':len(before),'unique_hand_labels':len(labels),'variants':37,'repeat_identical':args.repeat,'text_hash_policy':'canonical LF; raw bytes compared during repeat','output_sha256':canonical}
    (ROOT/'assets/validation_5218/asset-checks.json').write_text(json.dumps(result,indent=2)+'\n')
    print(f'Checked {len(before)} outputs; repeat_identical={args.repeat}; 1850 hand labels.')
if __name__=='__main__':main()

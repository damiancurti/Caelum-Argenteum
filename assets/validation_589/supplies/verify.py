"""Check deterministic generation and the immutable package against current sources."""
from pathlib import Path
import hashlib,json,runpy,zipfile
ROOT=Path(__file__).resolve().parents[3]
files=['src/LANGUAGE','src/caelum/data/CaelumChemistryData.zs','src/caelum/data/chemistry_resources.modeldef','src/caelum/data/chemistry_resources.textures']
before={n:(ROOT/n).read_bytes() for n in files}
runpy.run_path(str(ROOT/'assets/generators/generate_chemistry_recipes.py'),run_name='__main__')
assert all((ROOT/n).read_bytes()==v for n,v in before.items())
for row in json.loads((ROOT/'assets/art_source/hygiene/RUNTIME.json').read_text(encoding='utf-8')):
 assert (ROOT/row['source']).read_bytes()==(ROOT/row['runtime']).read_bytes()
 assert hashlib.sha256((ROOT/row['runtime']).read_bytes()).hexdigest()==row['sha256']
package=ROOT/'build/issue502/supplies02/caelum_argenteum_dev.pk3'
with zipfile.ZipFile(package) as z:
 assert all(z.read(n)==(ROOT/'src'/n).read_bytes() for n in z.namelist())
 assert len(z.namelist())==sum(p.is_file() for p in (ROOT/'src').rglob('*'))
print('PASS deterministic chemistry generation, four unchanged painted exports, complete immutable package.')

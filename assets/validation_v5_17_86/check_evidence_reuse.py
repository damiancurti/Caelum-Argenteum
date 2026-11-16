"""Bound reused evidence to byte-identical unaffected model dependencies."""
from pathlib import Path
import argparse,hashlib,json,zipfile

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
 p=argparse.ArgumentParser(description=__doc__)
 for name in ['before','after','visual-before','output']:p.add_argument('--'+name,type=Path,required=True)
 a=p.parse_args();model='models/caelum/folklore/australfigures/'
 with zipfile.ZipFile(a.before) as before,zipfile.ZipFile(a.after) as after,zipfile.ZipFile(a.visual_before) as visual:
  assert set(before.namelist())==set(after.namelist())==set(visual.namelist())
  changed=sorted(n for n in before.namelist() if before.read(n)!=after.read(n))
  assert changed==[model+'halahaches.md3'],changed
  visual_changed=sorted(n for n in visual.namelist() if visual.read(n)!=after.read(n))
  assert visual_changed==[model+'halahaches.md3',model+'tanu.md3'],visual_changed
  proof=dict(issue=815,before_sha256=sha(a.before),final_sha256=sha(a.after),visual_before_sha256=sha(a.visual_before),
   changed_resources=changed,earlier_visual_changed_resources=visual_changed,
   reused_continuity=['shoort','tanu','matan','ulen'],reused_visual02=['shoort','matan','ulen'],reused_visual03=['tanu'],
   scope='Only Halahaches model geometry changed after native01. Unaffected model/material/binding, actor code, save definitions, maps and all other runtime bytes are identical. Reuse four species continuity results and their static art views; rerun Halahaches continuity/art and all native actions on the final package. Presentation uses the final package for every species.',
   resource_hashes={n:hashlib.sha256(after.read(n)).hexdigest() for n in after.namelist() if n.startswith(model)})
 a.output.write_text(json.dumps(proof,indent=2)+'\n',encoding='utf-8',newline='\n')
 print(json.dumps(dict(passed=True,changed_resources=changed)))

if __name__=='__main__':main()

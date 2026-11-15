"""Audit active authored sweeps and reject the nine recorded pre-fix grids."""
from pathlib import Path
import argparse,json,sys

def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--root',type=Path,required=True);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
 root=args.root.resolve(strict=True);out=args.output.resolve();out.relative_to(root/'build');sys.path.insert(0,str(root/'assets/generators'))
 from validate_beast_men_models import validate_sweep_grid
 source_files=set()
 for path in (root/'assets/source/art').glob('*/ANIMATION.json'):
  data=json.loads(path.read_text(encoding='utf-8'))
  for species in data.get('species',{}).values():
   if isinstance(species,dict) and 'design' in species:source_files.add(species['design'])
 counts={}
 for name in sorted(source_files):
  data=json.loads((root/name).read_text(encoding='utf-8'));count=0
  for shape in data.get('shapes',[]):
   validate_sweep_grid(shape,name)
   count+=shape['kind']=='sweep'
  if count:counts[name]=count
 before=json.loads((root/'assets/validation_v5_17_78/native-uv-before.json').read_text());rejected=[]
 for row in before['rows']:
  shape=dict(kind='sweep',part=row['shape'],name=row['shape'],samples=row['samples'],uv_repeats=row['uv_repeats'])
  try:validate_sweep_grid(shape,row['source'])
  except AssertionError as exc:
   assert row['shape'] in str(exc) and 'material cell' in str(exc);rejected.append(str(exc))
  else:raise AssertionError('The regression guard accepted '+row['shape'])
 assert len(rejected)==9
 report=dict(issue=799,active_design_files=len(source_files),sweeps=sum(counts.values()),sweeps_by_source=counts,old_invalid_grids_rejected=rejected,passed=True)
 out.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(dict(passed=True,active_designs=len(source_files),sweeps=sum(counts.values()),rejected=len(rejected))))

if __name__=='__main__':main()

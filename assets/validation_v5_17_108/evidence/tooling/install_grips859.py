"""Install the tested finite grip candidate and advance release markers."""
from pathlib import Path
import json,re,shutil,subprocess
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');art=root/'assets/source/art/grips_859'
assert subprocess.check_output(['git','branch','--show-current'],cwd=root,text=True).strip()=='issue859-first-body-grips'
for name in ['grips.blend','AUTHORING.json']:shutil.copyfile(root/'build/issue859-source01'/name,art/name)
shutil.copyfile(root/'build/issue859-export01/manifest.json',art/'EXPORT.json')
subprocess.run(['python','-X','utf8','assets/generators/build_equipment_grip_bindings.py','--export','build/issue859-export01','--output','build/issue859-install01','--install'],cwd=root,check=True)
for name in ['AGENTS.md']+['docs/'+n for n in ('ASSETS.md','CONTEXT.md','HISTORY.md','MAP01.txt','PROJECT.md','SPRITE_ART_DIRECTION.md','SYSTEMS.md','TASKS.md')]:
    path=root/name;source=path.read_text(encoding='utf-8');opening,tail=source[:1000],source[1000:]
    opening,count=re.subn(r'(Documentation version:\s*(?:\*\*)?)5\.17\.107',r'\g<1>5.17.108',opening,count=1);assert count==1,name
    path.write_text(opening+tail,encoding='utf-8',newline='\n')
path=root/'README.md';source=path.read_text(encoding='utf-8');assert source.count('Current release: 5.17.107.')==1
path.write_text(source.replace('Current release: 5.17.107.','Current release: 5.17.108.',1),encoding='utf-8',newline='\n')
for name in ('CaelumPhysicalHazards.zs','CaelumSewerMaze.zs'):
    path=root/'src/caelum/world'/name;data=path.read_bytes();assert data.count(b'[Caelum 5.17.107]')==1
    path.write_bytes(data.replace(b'[Caelum 5.17.107]',b'[Caelum 5.17.108]'))
provenance={'issue':859,'author_accepted':False,'anatomy':'CC0-1.0 derived; see ../underbody_827/PROVENANCE.json and ../domingo_3d_pilot/makehuman/LICENSE.ASSETS.md','anatomy_upstream_commit':'3c701a8e52f09e69922e8b598d23be2d7dfc49e3','owned_sources':['../domingo_3d_pilot/PROVENANCE.json','../worn_clothing_829/PROVENANCE.json'],'modifications':['Derive finger landmarks from retained CC0 topology using the existing #827 hand transform.','Bake finite closed hand variants using editable construction bones; retain shared wrist coordinates and original native skin weights.','Fit existing sword and shield rigidly to those grips; no redesigned equipment or new textures.','Derive the four glove shells from fitted hands while retaining the original #829 offsets and UV coordinates.','Export all 375 original action samples with compensating attachment transforms to maintain grip contact; all source rig actions and gameplay timings remain unchanged.'],'preserved':['Every source file/hash listed in DESIGN.json.','Original default model modules, original garment modules, atlas pixels, all gameplay identities and saved fields.'],'native_notice':'src/licenses/GRIPS_859.txt'}
(art/'PROVENANCE.json').write_text(json.dumps(provenance,indent=2)+'\n',encoding='utf-8')
(root/'src/licenses/GRIPS_859.txt').write_text('First-body equipment grip candidates, issue #859.\n\nAnatomy derives from the retained MakeHuman CC0 base through #827/#829.\nSee MAKEHUMAN_CC0.txt and UNDERBODY_827.txt. Source provenance, exact\ninput hashes and modifications: assets/source/art/grips_859/PROVENANCE.json\nand DESIGN.json in the repository. The original owned Domingo equipment,\nskin atlas and glove textures remain unchanged. New derivatives are finite\nclosed-grip meshes and rigid visual attachment fits; no Doom assets are added.\nAuthor visual acceptance remains pending.\n',encoding='utf-8')
evidence=root/'assets/validation_v5_17_108';evidence.mkdir(exist_ok=True)
runner=Path(__file__).with_name('run_grip_motion859.py').read_text().replace("ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')","ROOT=Path(__file__).resolve().parents[2]")
(evidence/'run_grip_motion859.py').write_text(runner,encoding='utf-8',newline='\n')
path=root/'.gitattributes';source=path.read_text(encoding='utf-8')
source+='\n# Finite first-body equipment grip sources and native evidence (#859).\nassets/source/art/grips_859/*.json text eol=lf\nassets/source/art/grips_859/*.blend -text -diff\nassets/validation_v5_17_108/** -text -diff\nassets/validation_v5_17_108/*.py text eol=lf diff\nassets/validation_v5_17_108/*.json text eol=lf diff\nassets/generators/author_equipment_grips.py text eol=lf\nassets/generators/export_equipment_grips.py text eol=lf\nassets/generators/build_equipment_grip_bindings.py text eol=lf\nsrc/licenses/GRIPS_859.txt text eol=lf\n'
path.write_text(source,encoding='utf-8',newline='\n')
print('Installed #859 finite models, source and 5.17.108 markers; final qualification pending.')

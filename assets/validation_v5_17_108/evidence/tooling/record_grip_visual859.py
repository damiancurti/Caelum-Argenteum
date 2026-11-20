"""Record only images directly inspected in this session."""
from pathlib import Path
import json,hashlib
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');rows=[]
groups={
'issue859-inspect01':['right-front','right-side','left-front','right-rear'],
'issue859-grip-study01':['right-front','left-inside'],
'issue859-grip-study02':['right-front','left-inside'],
'issue859-grip-study03':['right-front','left-inside','left-front','right-rear'],
'issue859-grip-study04':['right-rear','left-inside'],
'issue859-grip-study05':['right-rear','left-inside','right-front','left-front'],
'issue859-native01':['run','attack'],
'issue859-bare01':['grip-front','grip-other'],
'issue859-bare02':['grip-front','guard-grip','landing','death'],
'issue859-final01/bare':['grip-rear','guard-rear'],
'issue859-final02/bare':['walk','run','attack','guard','jump-air','landing','death-side','grip-front'],
'issue859-final02/GF':['grip-front','run'],
'issue859-final02/GC':['grip-front','run'],
'issue859-final02/GW':['grip-front','run'],
'issue859-final02/GP':['grip-front','run'],
'issue859-close-right02':['grip-front','run'],
'issue859-close-right03':['grip-front','run'],
'issue859-close-right04':['grip-front','run'],
}
for directory,names in groups.items():
 for name in names:
  p=root/'build'/directory/(name+'.png');rows.append({'path':p.relative_to(root).as_posix(),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'final_evidence':directory.startswith('issue859-final02') or directory=='issue859-close-right04'})
report={'issue':859,'directly_viewed':rows,'notes':['Source studies01-04 were rejected; study05 established the final finite-grip geometry before explicit seam freezing and original glove UV retention.','All prototype01/export01/02/runtimegrips01 native images are rejected final evidence because raw shield topology omitted Solidify back geometry.','bare01 mistakenly retained native starting gloves; bare02 fixes that fixture case.','close-right01 aborted in its diagnostic static-array lookup; no image reviewed. The exact engine/compiler cause was not isolated.','close-right02 and03 passed native checks but were misframed;04 uses literal sampled anchors, CameraHeight0 and the actual level.pixelstretch compensation, verified against GZDoom4.14.2 models.cpp and actorinlines.h.','Final images retain the source low-poly construction anatomy/flat sampled skin and existing garment, face, hair and death-pose limitations; this does not establish author acceptance of the broader body or #736.']}
(root/'build/issue859-visual-review.json').write_text(json.dumps(report,indent=2)+'\n');print('Recorded',len(rows),'directly viewed images;',sum(r['final_evidence'] for r in rows),'final-qualified so far.')

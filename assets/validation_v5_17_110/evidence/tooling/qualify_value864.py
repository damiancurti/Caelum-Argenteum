"""Record the six explicitly inspected native images and their limits."""
from pathlib import Path
import hashlib, json, shutil, subprocess, sys
from PIL import Image

root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');dest=root/'assets/validation_v5_17_110';evidence=dest/'evidence'
p=evidence/'SUMMARY.json';summary=json.loads(p.read_text());assert summary['direct_visual_review_pending']
viewed=[]
for row in summary['captures']:
    path=dest/row['path'];size=list(Image.open(path).size);assert size==[1280,720]
    viewed.append(dict(path=path.relative_to(root).as_posix(),sha256=hashlib.sha256(path.read_bytes()).hexdigest(),pixels=size))
review=dict(explicitly_viewed=viewed,count=6,requested_resolution=[1280,720],actual_resolution=[1280,720],
    observations='Both siege views retain the same gateway/ram framing. Mansion opening dialogue is visible and preserved. Sewer entrance, city transport frontage and downward paving view render with the retained assets. Diagnostic console notifications remain in captures. No visual or route acceptance is inferred.')
(root/'build/issue864-visual-review.json').write_text(json.dumps(review,indent=2)+'\n',encoding='utf-8')
(evidence/'visual-review.json').write_text(json.dumps(review,indent=2)+'\n',encoding='utf-8',newline='\n')
summary['direct_visual_review_pending']=False;summary['direct_visual_review']=review
p.write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8',newline='\n')
p=root/'docs/HISTORY.md';s=p.read_text(encoding='utf-8');a=s.index('## 5.17.110 -');b=s.index('\n## ',a+1);section=s[a:b]
anchor='Queue presents are application submissions, not monitor scanout.';assert section.count(anchor)==1
section=section.replace(anchor,'Six native images were directly inspected and fingerprinted; each is1280x720,\nmatching the requested resolution. The mansion opening dialogue and diagnostic\nnotifications remain visible. The siege gateway, sewer entrance and city transport/\npaving references retain their existing presentation.\n\n'+anchor)
p.write_text(s[:a]+section+s[b:],encoding='utf-8',newline='\n')
shutil.copyfile(Path(__file__),evidence/'tooling/qualify_value864.py')
subprocess.run([sys.executable,'build_document_index.py'],cwd=root,check=True,stdout=subprocess.DEVNULL)
print('Recorded all six explicitly inspected1280x720 native captures.')

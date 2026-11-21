"""Build the deterministic source/native comparison gallery for #866."""
from pathlib import Path
import html
import json

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/environment_remasters_866'
EVIDENCE=ROOT/'assets/validation_v5_17_111/evidence'


def main():
    inventory=json.loads((SOURCE/'INVENTORY.json').read_text())
    reports=json.loads((EVIDENCE/'SUMMARY.json').read_text())
    prefix='../../../validation_v5_17_111/evidence/'
    style='''body{margin:0;background:#191916;color:#ede9df;font:16px/1.5 system-ui,sans-serif}main{max-width:1400px;margin:auto;padding:30px}a{color:#d6be83}h1,h2{line-height:1.2}section{margin:32px 0;padding:20px;background:#24241f;border:1px solid #4a493d}.pair{display:grid;grid-template-columns:1fr 1fr;gap:18px}figure{margin:0}img{display:block;width:100%;height:auto}figcaption{padding:8px 0}.source img{width:100%;max-width:512px}.notice{border-left:4px solid #c7aa68;padding:12px 18px;background:#303026}code{overflow-wrap:anywhere}nav{display:flex;gap:18px;flex-wrap:wrap}@media(max-width:700px){.pair{grid-template-columns:1fr}main{padding:14px}}'''
    page=['<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">',
          '<title>Caelum Argenteum — retained environment material review #866</title><style>'+style+'</style><main>',
          '<h1>Retained environment materials</h1><p>Issue #866 · 5.17.111 · author review pending</p>',
          '<p class="notice">These eight remasters come from the author’s original pack. Production assets remain active. The review overlay changes shared aliases globally while loaded; use its dedicated session. No visual acceptance is assumed.</p>',
          '<nav><a href="#sources">Sources</a><a href="#native">Native comparisons</a><a href="#performance">Measured scenes</a><a href="INVENTORY.json">Consumer inventory</a><a href="PROVENANCE.json">Provenance</a><a href="PROMPTS.json">Original prompts</a></nav>',
          '<p>The supplied 512×512 exports retain a 128-MU / 4-m repeat. Eight unique RGBA base images cost an estimated 8 MiB, or about 10.67 MiB with mipmaps; this is not measured VRAM. Separate alias allocations may cost more.</p>',
          '<p>CMWIN36, CSUFA0, CTFWA0 and the mansion door gable still use original raw images. Other mansion compositions and city brick/props also retain their existing art. The candidate does not finish all scenery.</p>',
          '<h2 id="sources">Exact source images</h2>']
    names={'CMEX01':'Aged lime plaster','CMEX04':'Handmade red brick','CMST01':'Irregular cobbles','CMST02':'Squared stone paving','CMWD01':'Dark wood planks','CMTB04':'Terracotta roof tiles','CMGR01':'Dark grass','CMGR02':'Sparse grass and earth'}
    def pair(left,right,left_label,right_label,source=False):
        result=['<div class="pair'+(' source' if source else '')+'">']
        for path,label in [(left,left_label),(right,right_label)]:
            assert (SOURCE/path).is_file(),path
            result.append(f'<figure><a href="{path}"><img loading="lazy" src="{path}" alt="{html.escape(label)}"></a><figcaption>{html.escape(label)}</figcaption></figure>')
        return ''.join(result)+'</div>'
    for row in inventory['exports']:
        name=Path(row['file']).stem
        page+=['<section><h3>'+name+' — '+names[name]+'</h3>',pair('references/'+name+'.png','exports/'+name+'.png','Original reference · 128×128','Supplied remaster · 512×512',True),f'<p><a href="masters/{name}.png">Original 1254×1254 master</a></p></section>']
    page+=['<h2 id="native">Native before / after</h2><p>Fixed camera, unchanged lighting and geometry. Captures are 1520×825 despite the requested 1280×720. Diagnostic teleports, menu dismissal, invulnerability and notarget are disclosed. The repeat laboratory places every material on all planes for inspection; grass walls and tiled floors are not campaign proposals.</p>']
    for row in reports['view_sets']:
        report=json.loads((EVIDENCE/'views'/row/'RESULTS.json').read_text())
        for view in report['cameras']:
            stem=view['name'];base=prefix+'views/'+row+'/'
            page+=['<section><h3>'+html.escape(report['map']+' / '+stem)+'</h3>',pair(base+'control/'+stem+'.png',base+'candidate/'+stem+'.png','Current production materials','Supplied candidate'),'<p>'+html.escape(view['basis'])+'</p></section>']
    page+=['<h2 id="performance">Native performance references</h2><p>Serial 1280×720 Vulkan windows, unpaused background and 5% audio. Queue presentation is not monitor scanout. A single pair does not prove a stable cost difference. The mansion retains its opening dialogue; siege fluency remains unresolved. Full tails and state: <a href="'+prefix+'performance.json">performance.json</a>.</p>']
    scenes=json.loads((EVIDENCE/'performance.json').read_text())
    for i in range(0,len(scenes),2):
        old,new=scenes[i:i+2]
        page+=['<section><h3>'+html.escape(old['label'].split('-')[0])+'</h3>',pair(prefix+'scenes/'+old['label']+'/peer0/scene.png',prefix+'scenes/'+new['label']+'/peer0/scene.png',f"Control · {old['presentation']['mean_present_fps']:.3f} queue presents/s",f"Candidate · {new['presentation']['mean_present_fps']:.3f} queue presents/s"),'</section>']
    page+=['<p>CA866-MATERIAL-01 remains pending for the consolidated author session. Repeated wear patterns, grass contrast and shared-surface coverage require artistic judgment.</p></main></html>']
    (SOURCE/'review.html').write_text('\n'.join(page)+'\n',encoding='utf-8',newline='\n')
    print('Built environment review gallery.')


if __name__=='__main__':main()

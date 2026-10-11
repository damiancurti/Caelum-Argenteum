"""Check #185 equivalence, determinism and negative freshness cases."""
from pathlib import Path
import hashlib
import json
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from build_dialogue_index import blocks, field, language_index, load_catalogue, outputs, tokens, validate

HERE = Path(__file__).resolve().parent
SOURCE = ROOT / 'src'
BASE = '0894d41d'


def main():
    checks = []
    def check(name, result):
        checks.append(dict(name=name, passed=bool(result)))
    original = subprocess.check_output(['git','show',BASE+':src/CAPALOMO'],cwd=ROOT).decode('utf-8')
    runtime = (SOURCE/'dialogues/runtime.usdf').read_text(encoding='utf-8')
    baseline_language = subprocess.check_output(['git','show',BASE+':src/LANGUAGE'],cwd=ROOT).decode('utf-8')
    check('All original dialogue tokens and global node order retained', [m[0] for m in tokens(original)] == [m[0] for m in tokens(runtime)])
    check('LANGUAGE content retained (only line-ending normalization)', baseline_language.replace('\r\n','\n') == (SOURCE/'LANGUAGE').read_text(encoding='utf-8'))
    check('Original source archived without content loss', (ROOT/'archive/dialogues/5.2.4-CAPALOMO.usdf').read_text(encoding='utf-8') == original.replace('\r\n','\n'))
    first = outputs(ROOT,SOURCE); second = outputs(ROOT,SOURCE)
    check('Repeated generation is byte-for-byte deterministic', first == second)
    check('All committed output files match generation', all(p.read_bytes() == t.encode('utf-8') for p,t in first.items()))
    check('Production source validates', not validate(ROOT))
    data=language_index(SOURCE/'LANGUAGE'); lines=(SOURCE/'LANGUAGE').read_text(encoding='utf-8').splitlines()
    check('Every localization location starts at its exact key and ends at a semicolon',
          all(lines[start-1].lstrip().startswith(key+' ') and lines[end-1].rstrip().endswith(';')
              for key,langs in data['entries'].items() for ranges in langs.values() for start,end in ranges))
    before=(SOURCE/'caelum/dialogue/CaelumDialogueHistoryData.zs').read_text(encoding='utf-8')
    subprocess.run([sys.executable,'assets/generators/generate_dialogue_history.py'],cwd=ROOT,check=True)
    check('History generation preserves the reviewed catalogue', before == (SOURCE/'caelum/dialogue/CaelumDialogueHistoryData.zs').read_text(encoding='utf-8'))
    cases = ('source-comment','language-comment','runtime','duplicate-id','missing-key','missing-page','mapinfo','history','unlisted-source','syntax-comments')
    for case in cases:
        root=ROOT/'build/issue185/check-cases'/case; src=root/'src'
        for path in [*list((SOURCE/'dialogues').rglob('*')),*list((SOURCE/'localization').rglob('*')), SOURCE/'LANGUAGE',SOURCE/'MAPINFO']:
            if path.is_file():
                target=src/path.relative_to(SOURCE);target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(path,target)
        history=root/'assets/dialogue_history.json';history.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/'assets/dialogue_history.json',history)
        target=src/'dialogues/npc/palomo.usdf'
        if case=='source-comment': target.write_text(target.read_text(encoding='utf-8')+'\n// changed\n',encoding='utf-8',newline='\n')
        elif case=='language-comment':
            target=src/'LANGUAGE';target.write_text(target.read_text(encoding='utf-8')+'\n// changed\n',encoding='utf-8',newline='\n')
        elif case=='runtime':
            target=src/'dialogues/runtime.usdf';target.write_text('stale',encoding='utf-8')
        elif case=='duplicate-id':
            target.write_text(target.read_text(encoding='utf-8').replace('id = 43200','id = 43310'),encoding='utf-8',newline='\n')
        elif case=='missing-key':
            target.write_text(target.read_text(encoding='utf-8').replace('$CA_PALOMO_NAME','$CA_MISSING_TEST_KEY'),encoding='utf-8',newline='\n')
        elif case=='missing-page':
            target.write_text(target.read_text(encoding='utf-8').replace('nextpage = "palomo_answer_where"','nextpage = "missing_test_page"'),encoding='utf-8',newline='\n')
        elif case=='mapinfo':
            target=src/'MAPINFO';target.write_text('GameInfo { AddDialogues = "CAPALOMO" }',encoding='utf-8')
        elif case=='history':
            obj=json.loads(history.read_text(encoding='utf-8'));obj['entries'][0]['page']='missing_page';history.write_text(json.dumps(obj),encoding='utf-8')
        elif case=='unlisted-source':
            (src/'dialogues/npc/unlisted.usdf').write_text('namespace = "GZDoom";',encoding='utf-8')
        elif case=='syntax-comments':
            target.write_text('// leading semicolon ;\n'+target.read_text(encoding='utf-8').replace('nextpage =','NextPage =')+'\n// nextpage = "comment_only";\n',encoding='utf-8',newline='\n')
            generated=outputs(root,src)
            check('Comments and legal identifier case preserve compiled dialogue',
                  [m[0].lower() if not m[0].startswith('"') else m[0] for m in tokens(generated[src/'dialogues/runtime.usdf'])] ==
                  [m[0].lower() if not m[0].startswith('"') else m[0] for m in tokens(runtime)])
        check('Reject '+case, bool(validate(root)))
    manifest, conversations=load_catalogue(SOURCE)
    report=dict(base=BASE,checks=len(checks),failures=sum(not c['passed'] for c in checks),
                conversations=len(conversations),pages=sum(len(b['pages']) for b in conversations),
                sources=len(manifest['sources']),localization_keys=len(data['entries']),results=checks,
                hashes={p.relative_to(ROOT).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in first})
    (HERE/'static-audit.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(f'#185: {report["checks"]} checks, {report["failures"]} failures; {report["conversations"]} conversations, {report["pages"]} pages, {report["localization_keys"]} keys')
    for entry in checks:
        if not entry['passed']: print('FAIL:',entry['name'])
    return bool(report['failures'])


if __name__=='__main__':
    raise SystemExit(main())

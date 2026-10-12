"""Persist selected #209 sources, references and reproducible provenance."""
from pathlib import Path
import hashlib
import json
import shutil

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/appearance_5218'

def main():
    manifest=json.loads((SOURCE/'PROVENANCE.json').read_text(encoding='utf-8'))
    replaced={'sleep_v1.png','female_hands_human_v1.png','female_gloves_v1.png','female_wolf_v1.png'}
    for entry in manifest['assets']:
        entry['status']='superseded source retained' if entry['file'] in replaced else 'selected; author visual acceptance pending'
        path=SOURCE/entry['file'];entry['sha256']=hashlib.sha256(path.read_bytes()).hexdigest()
        references=[]
        for reference in entry['references']:
            path=Path(reference)
            # Original prompts used local absolute paths; persist every build
            # reference and record portable paths without changing the prompt.
            if path.is_absolute():path=path.relative_to(ROOT)
            if path.parts[0]=='build':
                destination=SOURCE/'references'/path.name
                destination.parent.mkdir(exist_ok=True)
                shutil.copy2(ROOT/path,destination)
                path=destination.relative_to(ROOT)
            references.append(path.as_posix())
        entry['references']=references
        entry['reference_sha256']={p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in references}
    manifest['author_decisions']=['Supine sleep','Domingo poses and anatomical forms except rear attack','Distinct female first-person hands','Modular plain clothes, sex/race/tone/gloves retained']
    manifest['processing']='Pillow 11.3.0; deterministic crop/alpha cleanup/registration; source paintings remain intact.'
    (SOURCE/'PROVENANCE.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')

if __name__=='__main__':main()

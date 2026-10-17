"""Publish sanitized diagnostic evidence, without packages, saves or executables."""
from pathlib import Path
import gzip
import hashlib
import json
import re
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
DEST=HERE/'evidence'
PERF_KEYS={'vid_preferbackend','vid_rendermode','vid_vsync','vid_maxfps','cl_capfps','vid_activeinbackground',
           'i_pauseinbackground','vid_lowerinbackground','i_soundinbackground','snd_mastervolume','vid_fullscreen',
           'vid_defwidth','vid_defheight','vid_fps','gl_portals','gl_lights','r_dynlights','r_actorspriteshadow',
           'r_drawplayersprites','screenblocks','fov'}
PERF_PREFIXES=('gl_','r_','vid_','vk_')

def digest(data):return hashlib.sha256(data).hexdigest()

def sanitize(text):
    # Both JSON-escaped and ordinary paths occur in the evidence.
    replacements=[(str(ROOT),'$REPO'),(r'C:\Program Files (x86)\GZDoom','$ENGINE_DIR'),
                  (r'C:\Program Files (x86)\Steam\steamapps\common\ultimate doom\base\doom2','$IWAD_DIR'),
                  (r'C:\Program Files (x86)\Steam\steamapps\common\Ultimate Doom','$DEV_GAME_DIR'),
                  (str(Path.home()),'$USER_DIR')]
    for original,target in replacements:
        for form in (original.replace('\\','\\\\'),original,original.replace('\\','/')):text=text.replace(form,target)
    return text

def main():
    DEST.mkdir(exist_ok=True);manifest=[]
    def save(relative,raw,public=None,compressed=True):
        public=raw if public is None else public;out=DEST/(relative+('.gz' if compressed else ''))
        out.parent.mkdir(exist_ok=True,parents=True)
        out.write_bytes(gzip.compress(public,mtime=0) if compressed else public)
        manifest.append({'file':out.relative_to(HERE).as_posix(),'local_sha256':digest(raw),
                         'public_sha256':digest(public),'public_bytes':len(public),'sanitized':raw!=public})
    for folder in sorted((ROOT/'build').glob('issue318-*')):
        if not folder.is_dir():continue
        for path in sorted(folder.glob('*/*')):
            if path.parent.name=='engine-source':continue
            if path.suffix not in ('.txt','.cfg','.json'):continue
            if path.name in ('benchmarks.txt',):continue
            if path.name.endswith('-run.json'):
                obj=json.loads(path.read_text());original=obj.pop('initial_config','')
                obj['initial_config_sha256']=digest(original.encode())
                obj['initial_performance_settings']={k:v for k,v in re.findall(r'^([^=\r\n]+)=([^\r\n]*)',original,re.M) if k in PERF_KEYS or k.startswith(PERF_PREFIXES)}
                obj['public_record_note']='Private paths and unrelated user configuration omitted; local original hash retained.'
                public=sanitize(json.dumps(obj,indent=2)+'\n').encode()
            else:public=sanitize(path.read_text(encoding='utf-8',errors='replace')).encode()
            save(path.relative_to(ROOT/'build').as_posix(),path.read_bytes(),public)
        for path in sorted(folder.glob('*.json')):
            save(path.relative_to(ROOT/'build').as_posix(),path.read_bytes(),sanitize(path.read_text()).encode(),compressed=path.name!='analysis.json')
        csv=folder/'presentmon-global.csv'
        if csv.exists():save(csv.relative_to(ROOT/'build').as_posix(),csv.read_bytes())
        for csv in sorted(folder.glob('*/*.csv')):
            save(csv.relative_to(ROOT/'build').as_posix(),csv.read_bytes())
    analysis=ROOT/'build/issue318-audit-02/analysis.json'
    save('analysis.json',analysis.read_bytes(),sanitize(analysis.read_text()).encode(),compressed=False)
    # Preserve the observer revisions actually used; these are owned source, not fixtures.
    work=ROOT/'build/issue318-audit-02'
    for label,path in [('v2',work/'base/observer.pk3'),('v3',work/'observer-v3.pk3'),('v4',work/'observer-v4.pk3'),('v5',work/'observer-v5.pk3')]:
        with zipfile.ZipFile(path) as archive:raw=archive.read('observer.zs')
        save('observers/observer-'+label+'.zs',raw,compressed=False)
    for label in ('render-01-base','render-03-base','references-01-base','references-06-base','geometry2-01-base'):
        path=work/'base'/(label+'.png')
        if path.exists():save('captures/'+path.name,path.read_bytes(),compressed=False)
    # External engine source stays local; publish only URLs/hashes and short research notes.
    for name in ('review-source-manifest.json',):
        path=work/'engine-source'/name
        if path.exists():save('research/'+name,path.read_bytes(),sanitize(path.read_text()).encode(),compressed=False)
    (HERE/'EVIDENCE_MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print('Archived',len(manifest),'artifacts;',sum(x['public_bytes'] for x in manifest),'public uncompressed bytes')

if __name__=='__main__':main()

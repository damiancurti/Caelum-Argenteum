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
            # These local inspections contain copied external UDMF excerpts.
            # Publish derived counts/attribution, not the supplied map source.
            if path.name in ('DOOR_INSPECTION.json','POLY2.json','HANDOFF.json'):continue
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
    for label in ('geometry-0-1-base','geometry-0-2-safe','geometry-0-5-closed-interiors'):
        path=ROOT/'build/issue318-geometry-01/base'/(label+'.png')
        if path.exists():save('captures/'+path.name,path.read_bytes(),compressed=False)
    for directory,label in [('issue318-city-example-03','street-north'),
                            ('issue318-city-example-03','street-down'),
                            ('issue318-hgc-city-03','south-avenue-east')]:
        path=ROOT/'build'/directory/'original'/(label+'.png')
        if path.exists():save('captures/'+directory+'-'+path.name,path.read_bytes(),compressed=False)
    for label in ('native-doors','native-map06-door'):
        path=ROOT/'build/issue318-native-08/current'/(label+'.png')
        if path.exists():save('captures/'+path.name,path.read_bytes(),compressed=False)
    for directory,variant,labels in (
        ('issue318-houses-07','current',('house-interior',)),
        ('issue318-houses-perf-02','houses-6000',('peace-0-1','peace-75-1','siege6000-1','interior-1')),
        ('issue318-houses-perf-02','opaque-6000',('peace-0-2','peace-75-2','siege6000-2','interior-2')),
        ('issue318-houses-perf-02','houses-1000',('siege1000-0-1','siege1000-4-1')),
        ('issue318-houses-perf-02','opaque-1000',('siege1000-0-2','siege1000-4-2')),
        ('issue318-houses-perf-03','houses-6000',('peace-0-1','peace-75-1','siege6000-1','house-interior-1')),
        ('issue318-houses-perf-03','opaque-6000',('peace-0-2','peace-75-2','siege6000-2','house-interior-2')),
        ('issue318-houses-perf-03','houses-1000',('siege1000-0-1','siege1000-4-1')),
        ('issue318-houses-perf-03','opaque-1000',('siege1000-0-2','siege1000-4-2')),
    ):
        for label in labels:
            path=ROOT/'build'/directory/variant/(label+'.png')
            if path.exists():save('captures/'+directory+'-'+variant+'-'+path.name,path.read_bytes(),compressed=False)
    for directory,variant in (
        ('issue318-houses-07','current'),('issue318-houses-08','current'),
        ('issue318-houses-09','current'),('issue318-houses-perf-01','houses-6000'),
        ('issue318-houses-perf-02','houses-6000'),
        ('issue318-houses-perf-03','houses-6000'),
    ):
        for fixture in ('checks.pk3','observer.pk3'):
            path=ROOT/'build'/directory/variant/fixture
            if not path.exists():continue
            with zipfile.ZipFile(path) as archive:
                for member in archive.namelist():
                    if member.endswith('.zs') or member in ('MAPINFO','CVARINFO'):
                        save('observers/'+directory+'/'+fixture+'/'+member,archive.read(member),compressed=False)
    for directory in ('issue318-flat-01','issue318-flat-1600-01'):
        for label in ('sprites-01','models-02','frozen-sprites-01','frozen-models-02',
                      'inventory-empty-02','sustained-sprites','sustained-models'):
            path=ROOT/'build'/directory/'current'/(label+'.png')
            if path.exists():save('captures/'+directory+'-'+path.name,path.read_bytes(),compressed=False)
        for fixture in ('observer.pk3','domingo.pk3','freeze.pk3','no-inventory.pk3'):
            path=ROOT/'build'/directory/'current'/fixture
            if path.exists():
                with zipfile.ZipFile(path) as archive:
                    for member in archive.namelist():
                        if member.endswith('.zs') or member in ('MODELDEF','MAPINFO','CVARINFO'):
                            save('observers/'+directory+'/'+fixture+'/'+member,archive.read(member),compressed=False)
    for directory,fixture,member in [('issue318-city-example','observer.pk3','probe.zs'),
                                   ('issue318-city-example-02','observer.pk3','probe.zs'),
                                   ('issue318-city-example-03','observer.pk3','probe.zs')]:
        path=ROOT/'build'/directory/'original'/fixture
        if path.exists():
            with zipfile.ZipFile(path) as archive:raw=archive.read(member)
            save('observers/'+directory+'.zs',raw,compressed=False)
    # External engine source stays local; publish only URLs/hashes and short research notes.
    for name in ('review-source-manifest.json',):
        path=work/'engine-source'/name
        if path.exists():save('research/'+name,path.read_bytes(),sanitize(path.read_text()).encode(),compressed=False)
    (HERE/'EVIDENCE_MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print('Archived',len(manifest),'artifacts;',sum(x['public_bytes'] for x in manifest),'public uncompressed bytes')

if __name__=='__main__':main()

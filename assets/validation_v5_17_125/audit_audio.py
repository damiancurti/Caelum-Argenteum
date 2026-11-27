"""Audit current beta audio without replacing assignments or reserve tracks."""
import argparse
import hashlib
import json
import math
import re
import sys
import subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]

def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()

def audit(root):
    src=root/'src'
    info=(src/'SNDINFO').read_text(encoding='utf-8')
    aliases={}
    for name,path in re.findall(r'^\s*([^$\s/][^\s=]*|caelum/[^\s=]+)\s*=\s*"([^"]+)"',info,re.M):
        aliases.setdefault(path,[]).append(name)
    code={p.relative_to(src).as_posix():p.read_text(encoding='utf-8-sig')
          for p in sorted(src.rglob('*')) if p.is_file() and (p.suffix in ['.zs','.mapinfo'] or p.name in ['MAPINFO','SNDINFO','TERRAIN'])}
    credits={p.relative_to(src).as_posix():p.read_text(encoding='utf-8-sig') for p in sorted((src/'licenses').glob('*')) if p.is_file() and p.suffix.lower() in ['.txt','.md']}
    for name in ['assets/audio_eventos_v1/EDICIONES_Y_FUENTES.json','assets/source/audio/breathing_514/PROVENANCE.json','assets/validation_5856/PROVENANCE.json']:
        credits[name]=(root/name).read_text(encoding='utf-8-sig')
    reserved=json.loads((root/'assets/source/audio/map_music_496/catalogue.json').read_text(encoding='utf-8'))['tracks']
    reserved_paths={row['runtime'].removeprefix('src/'):row for row in reserved}
    errors=[];records=[]
    for p in sorted(src.rglob('*')):
        if p.suffix.lower() not in ['.ogg','.mp3','.wav']:continue
        relative=p.relative_to(src).as_posix();names=aliases.get(relative,[])
        reference=[relative,p.stem,*names]
        consumers=[name for name,text in code.items() if name!='SNDINFO' and any(token in text for token in reference)]
        record={'path':relative,'sha256':digest(p),'bytes':p.stat().st_size,'aliases':names,'literal_consumers':consumers,
                'credit_records':[name for name,text in credits.items() if p.name in text or relative in text]}
        if relative.startswith('sounds/caelum/gathering/'):
            record['credit_records'].append('licenses/AUDIO_GATHERING_ISSUE89_CREDITS.md')
        if relative.startswith('sounds/caelum/enemies/rat/'):
            record['credit_records'].append('licenses/rat_audio_543.txt')
        if relative in reserved_paths:
            row=reserved_paths[relative]
            record['reserved_destination']=row['destination']
            record['credit_records'].append('assets/source/audio/map_music_496/PROVENANCE.json')
            if row['map_binding'] is not None or consumers:errors.append('Reserved track acquired an unapproved binding: '+relative)
        records.append(record)
    for path in aliases:
        if not (src/path).is_file():errors.append('Missing SNDINFO file: '+path)
    return {'issue':464,'scope':'Existing MAP01-MAP03 prologue audio; future tracks reserved',
            'sndinfo_sha256':digest(src/'SNDINFO'),'runtime_count':len(records),'reserved_tracks':len(reserved),
            'assets':records,'errors':errors,
            'qualification':'Literal consumers are a locator, not proof of placed emitters. Licensing decisions are retained in source notices and audited separately under #466.'}

def decode(root,report,tools):
    sys.path.insert(0,str(tools.resolve()))
    import soundfile as sf
    import numpy as np
    result={'decoder':'soundfile '+sf.__version__+'; libsndfile '+sf.__libsndfile_version__,'files':[],'errors':[],'container_differences':[]}
    for record in report['assets']:
        p=root/'src'/record['path'];frames=0;energy=0.;peak=0.;channels=0;first=None;last=None
        try:
            with sf.SoundFile(p) as source:
                rate=source.samplerate;channels=source.channels;codec=source.subtype
                while True:
                    block=source.read(65536,dtype='float64',always_2d=True)
                    if not len(block):break
                    if first is None:first=block[0].tolist()
                    last=block[-1].tolist();frames+=len(block)
                    peak=max(peak,float(np.abs(block).max()));energy+=float(np.square(block).sum())
                container_frames=source.frames
            if frames!=container_frames:
                import imageio_ffmpeg
                executable=Path(imageio_ffmpeg.get_ffmpeg_exe())
                native=subprocess.run([str(executable),'-hide_banner','-nostdin','-v','warning','-i',str(p),'-f','s16le','-acodec','pcm_s16le','-'],capture_output=True)
                other_frames=len(native.stdout)//(channels*2)
                if native.returncode or native.stderr or other_frames!=frames:
                    raise ValueError('Independent decoder disagrees: '+native.stderr.decode(errors='replace'))
                result['container_differences'].append({'path':record['path'],'advertised_frames':container_frames,
                    'decoded_frames':frames,'ffmpeg_frames':other_frames,'ffmpeg_sha256':digest(executable),
                    'qualification':'Both decoders finish without errors and agree on output; retain original bytes and record actual decoded duration.'})
            if not frames or not peak:raise ValueError('Empty or silent audio')
            result['files'].append({'path':record['path'],'sha256':record['sha256'],'frames':frames,'channels':channels,
                'sample_rate':rate,'duration_seconds':frames/rate,'codec':codec,'peak':peak,
                'rms':math.sqrt(energy/(frames*channels)),'first_frame':first,'last_frame':last})
        except Exception as exc:result['errors'].append({'path':record['path'],'error':str(exc)})
    return result

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--root',type=Path,default=ROOT)
    parser.add_argument('--output',type=Path,required=True);parser.add_argument('--decode-tools',type=Path)
    args=parser.parse_args();report=audit(args.root);args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    print(json.dumps({'files':report['runtime_count'],'reserved':report['reserved_tracks'],'errors':report['errors']}))
    if args.decode_tools:
        decoded=decode(args.root,report,args.decode_tools);args.output.with_name('decode.json').write_text(json.dumps(decoded,indent=2)+'\n')
        print(json.dumps({'decoded':len(decoded['files']),'errors':decoded['errors']}))
        report['errors']+=decoded['errors']
    raise SystemExit(bool(report['errors']))

"""Encode the author's original Ciudad master for Buenos Aires (#416)."""
from pathlib import Path
import argparse,hashlib,json,subprocess,wave
R=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('--ffmpeg',type=Path,required=True);a=p.parse_args()
master=R/'assets/audio_stock/music/Ciudad - Caelum Argenteum.wav';out=R/'src/music/CA_MUS_CIUDAD.ogg'
def digest(path):
 with path.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
with wave.open(str(master),'rb') as w:channels,width,rate,frames,compression,_=w.getparams()
assert (channels,width,rate,compression)==(2,2,48000,'NONE')
subprocess.run([str(a.ffmpeg),'-hide_banner','-loglevel','error','-nostdin','-y','-i',str(master),
 '-map','0:a:0','-map_metadata','-1','-c:a','libvorbis','-q:a','6','-threads','1','-fflags','+bitexact','-flags:a','+bitexact',str(out)],check=True)
decoded=subprocess.check_output([str(a.ffmpeg),'-hide_banner','-loglevel','error','-nostdin','-i',str(out),'-f','s16le','-acodec','pcm_s16le','-'])
assert abs(len(decoded)//(channels*width)-frames)<=1024
report={'issue':416,'source':master.relative_to(R).as_posix(),'runtime':out.relative_to(R).as_posix(),
 'author':'Damián Curti','tool':'Suno','suno_id':'3a1fceb7-138e-4064-bf5d-4eb554c6bb77','created':'2026-09-24T19:57:15Z',
 'assignment':'CABAIRES; explicitly selected by author 2026-10-29',
 'processing':'Complete stereo 48 kHz master; Vorbis quality 6; no filters, trimming or normalization.',
 'ffmpeg_sha256':digest(a.ffmpeg),'master_sha256':digest(master),'runtime_sha256':digest(out),
 'source_frames':frames,'decoded_frames':len(decoded)//(channels*width),'duration_seconds':frames/rate,'channels':channels,'sample_rate':rate}
target=R/'assets/validation_5856/PROVENANCE.json';target.parent.mkdir(exist_ok=True)
target.write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n',encoding='utf-8');print(report['runtime_sha256'],report['duration_seconds'])

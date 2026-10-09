"""Encode sampled native flight screenshots; this does not measure presentation FPS."""
from pathlib import Path
import argparse, hashlib, json, subprocess

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue137'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ffmpeg', type=Path, default=ROOT/'build/tool-deps/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe')
    args = parser.parse_args()
    if not args.ffmpeg.is_file():
        raise SystemExit('Supply a local ffmpeg executable with --ffmpeg; it is not distributed.')
    records = []
    for label in ['flight-video-before', 'flight-video-after']:
        frames = sorted(WORK.glob(label+'-movie-*.png'))
        assert len(frames) == 324
        assert all(frame.name == f'{label}-movie-{i:04d}.png' for i,frame in enumerate(frames))
        target = HERE / (label + '.mp4')
        cmd = [str(args.ffmpeg), '-hide_banner', '-loglevel', 'error', '-y',
               '-framerate', '35/2', '-i', str(WORK/(label+'-movie-%04d.png')),
               '-c:v', 'libx264', '-crf', '18', '-pix_fmt', 'yuv420p',
               '-movflags', '+faststart', str(target)]
        subprocess.run(cmd, check=True)
        subprocess.run([str(args.ffmpeg), '-v', 'error', '-i', str(target),
                        '-f', 'null', '-'], check=True, stdout=subprocess.DEVNULL)
        run = json.loads((HERE/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        records.append({'file':target.name, 'native_run':label, 'frames':324,
                        'frames_per_view':12, 'sample_interval_game_tics':2,
                        'encoded_frames_per_second':17.5, 'audio':False,
                        'views':'nine families: side, outgoing, incoming',
                        'package_sha256':run['package_sha256'],
                        'addon_sha256':run['addon_sha256'],
                        'sha256':hashlib.sha256(target.read_bytes()).hexdigest(),
                        'source_frame_sha256':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in frames}})
    (HERE/'VIDEOS.json').write_text(json.dumps(records,indent=2)+'\n',encoding='utf-8')
    print('Encoded and fully decoded both 324-frame native-flight comparisons.')


if __name__ == '__main__':
    main()

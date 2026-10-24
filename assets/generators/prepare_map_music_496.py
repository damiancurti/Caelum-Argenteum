"""Prepare the author's second soundtrack without altering the WAV masters.

Requires imageio-ffmpeg 0.6.0's FFmpeg 7.1 executable, passed explicitly.
The frozen catalogue, original WAVs and deterministic Vorbis outputs are tracked.
No normalization, fades, trimming, resampling or synthetic audio is applied.
"""
from pathlib import Path
import argparse
import hashlib
import json
import shutil
import subprocess
import wave

ROOT = Path(__file__).resolve().parents[2]
CATALOGUE = ROOT / 'assets/source/audio/map_music_496/catalogue.json'


def digest(path):
    return hashlib.file_digest(path.open('rb'), 'sha256').hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ffmpeg', type=Path, required=True)
    parser.add_argument('--import-from', type=Path)
    parser.add_argument('--output-root', type=Path, default=ROOT)
    args = parser.parse_args()
    catalogue = json.loads(CATALOGUE.read_text(encoding='utf-8'))
    report = {
        'issue': 496, 'author': 'Damián Curti', 'tool': 'Suno',
        'author_confirmation': '2026-10-24',
        'processing': 'Complete stereo 48-kHz recordings; Vorbis quality 6; no audio filters.',
        'ffmpeg_sha256': digest(args.ffmpeg),
        'ffmpeg_version': subprocess.check_output([str(args.ffmpeg), '-version'], text=True).splitlines()[0],
        'tracks': [],
    }
    for entry in catalogue['tracks']:
        master = ROOT / entry['source']
        if args.import_from:
            supplied = args.import_from / entry['original_filename']
            if master.exists() and digest(master) != digest(supplied):
                raise RuntimeError(f'Refusing to replace a different master: {master}')
            master.parent.mkdir(parents=True, exist_ok=True)
            if not master.exists():
                shutil.copyfile(supplied, master)
        with wave.open(str(master), 'rb') as wav:
            channels, width, rate, frames, compression, _ = wav.getparams()
            if (channels, width, rate, compression) != (2, 2, 48000, 'NONE'):
                raise RuntimeError(f'Unexpected master format: {master}')
        output = args.output_root / entry['runtime']
        output.parent.mkdir(parents=True, exist_ok=True)
        command = [str(args.ffmpeg), '-hide_banner', '-loglevel', 'error', '-nostdin',
                   '-y', '-i', str(master), '-map', '0:a:0', '-map_metadata', '-1',
                   '-c:a', 'libvorbis', '-q:a', '6', '-threads', '1',
                   '-fflags', '+bitexact', '-flags:a', '+bitexact', str(output)]
        subprocess.run(command, check=True)
        # Fully decode each output, not only its container header.
        decoded = subprocess.check_output([str(args.ffmpeg), '-hide_banner', '-loglevel',
            'error', '-nostdin', '-i', str(output), '-f', 's16le', '-acodec', 'pcm_s16le', '-'])
        if abs(len(decoded) // (channels * width) - frames) > 1024:
            raise RuntimeError(f'Decoded duration differs from the master: {output}')
        report['tracks'].append({**entry, 'source_sha256': digest(master),
            'runtime_sha256': digest(output), 'source_bytes': master.stat().st_size,
            'runtime_bytes': output.stat().st_size, 'sample_rate': rate,
            'channels': channels, 'source_frames': frames,
            'decoded_frames': len(decoded) // (channels * width),
            'duration_seconds': frames / rate})
        print(f"Prepared {entry['music_name']}: {frames / rate:.2f} s", flush=True)
    target = args.output_root / 'assets/source/audio/map_music_496/PROVENANCE.json'
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(report, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


if __name__ == '__main__':
    main()

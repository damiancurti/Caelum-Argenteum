"""Create deterministic PCM breathing loops from the author's CC0 recordings.

Requires the ffmpeg 7.1 binary bundled by imageio-ffmpeg 0.6.0. Pass --ffmpeg
explicitly; no download or dependency installation occurs in this generator.
Original recordings and the supplied credits remain unchanged in assets/source.
"""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import wave

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/source/audio/breathing_514"
OUTPUT = ROOT / "src/sounds/caelum/breathing"


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ffmpeg", type=Path, required=True)
    args = parser.parse_args()
    OUTPUT.mkdir(parents=True, exist_ok=True)
    sources = {
        "female": "HMNBrth_Breathless woman (ID 1345)_BigSoundBank.com.wav",
        "male": "man-breathing-deep-breathe-sound.flac",
    }
    manifest = {
        "issue": 140,
        "license": "CC0, as recorded in the author's SOURCES_AND_CREDITS.txt",
        "source_attachment": "https://github.com/user-attachments/files/33208310/Caelum_Argenteum_Issue_140_Breathing.zip",
        "ffmpeg_sha256": digest(args.ffmpeg),
        "ffmpeg_version": subprocess.check_output(
            [str(args.ffmpeg), "-version"], text=True
        ).splitlines()[0],
        "processing": "Whole recordings, mono 22050-Hz signed 16-bit PCM; loudness -23 LUFS / -2 dBTP; 20-ms endpoint fades. High level uses 4/3 tempo with pitch preserved. No synthetic or cloned voice.",
        "clips": {},
    }
    for sex, filename in sources.items():
        origin = SOURCE / filename
        for high in (False, True):
            name = sex + ("_high" if high else "")
            target = OUTPUT / (name + ".wav")
            # Reverse/fade/reverse applies the same short fade to the unknown
            # final duration without an approximate trim or encoded timestamp.
            filters = "aformat=channel_layouts=mono,loudnorm=I=-23:TP=-2:LRA=7"
            if high:
                filters += ",atempo=1.3333333333333333"
            filters += ",afade=t=in:d=0.02,areverse,afade=t=in:d=0.02,areverse"
            command = [str(args.ffmpeg), "-hide_banner", "-loglevel", "error", "-y",
                       "-i", str(origin), "-map_metadata", "-1", "-af", filters,
                       "-ar", "22050", "-ac", "1", "-c:a", "pcm_s16le",
                       "-fflags", "+bitexact", "-flags:a", "+bitexact", str(target)]
            subprocess.run(command, check=True)
            with wave.open(str(target), "rb") as wav:
                assert (wav.getnchannels(), wav.getsampwidth(), wav.getframerate()) == (1, 2, 22050)
                duration = wav.getnframes() / wav.getframerate()
            manifest["clips"][name] = {
                "source": filename, "source_sha256": digest(origin),
                "runtime": target.relative_to(ROOT).as_posix(),
                "runtime_sha256": digest(target), "duration_seconds": duration,
                "filters": filters,
            }
    (SOURCE / "PROVENANCE.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print("Prepared four deterministic breathing loops; originals preserved.")


if __name__ == "__main__":
    main()

"""Synthesize original rat cues deterministically; no recordings or downloads."""
from pathlib import Path
import hashlib
import json
import math
import random
import struct
import wave

ROOT = Path(__file__).resolve().parents[2]
DATA = Path(__file__).with_name("rat_audio.json")
OUT = ROOT / "src/sounds/caelum/enemies/rat"
MANIFEST = ROOT / "assets/validation_543/rat_audio.json"


def main():
    data = json.loads(DATA.read_text(encoding="utf-8"))
    rate = data["sample_rate"]
    OUT.mkdir(parents=True, exist_ok=True)
    records = {}
    for index, (name, clip) in enumerate(data["clips"].items()):
        rng = random.Random(data["seed"] + index)
        count = round(clip["seconds"] * rate)
        phase = 0.0
        samples = []
        previous_noise = 0.0
        for i in range(count):
            position = i / (count - 1)
            pulse = (position * clip["pulses"]) % 1.0
            envelope = math.sin(math.pi * min(1.0, pulse / 0.82)) ** 2 if pulse < 0.82 else 0.0
            envelope *= min(1.0, position * 100, (1 - position) * 100)
            frequency = clip["start_hz"] + (clip["end_hz"] - clip["start_hz"]) * position
            frequency *= 1 + 0.09 * math.sin(2 * math.pi * 38 * i / rate)
            phase += 2 * math.pi * frequency / rate
            noise = rng.uniform(-1, 1)
            rasp = (noise - previous_noise) * 0.5
            previous_noise = noise
            tone = math.sin(phase) + 0.22 * math.sin(phase * 2) + 0.08 * math.sin(phase * 3)
            samples.append(envelope * ((1 - clip["rasp"]) * tone + clip["rasp"] * rasp))
        peak = max(abs(v) for v in samples)
        pcm = [round(v / peak * data["peak"] * 32767) for v in samples]
        path = OUT / (name + ".wav")
        with wave.open(str(path), "wb") as audio:
            audio.setnchannels(1)
            audio.setsampwidth(2)
            audio.setframerate(rate)
            audio.writeframes(struct.pack("<" + "h" * count, *pcm))
        records[name] = {
            "file": path.relative_to(ROOT).as_posix(),
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
            "frames": count,
            "seconds": count / rate,
            "peak": max(abs(v) for v in pcm) / 32768,
            "rms": math.sqrt(sum(v * v for v in pcm) / count) / 32768,
            "endpoints": [pcm[0], pcm[-1]],
        }
    manifest = {
        "issue": 254,
        "origin": "Original procedural synthesis for Caelum Argenteum; no external audio inputs.",
        "rights_notice": "LICENSE.md; no third-party recording or Doom sound is included.",
        "source": DATA.relative_to(ROOT).as_posix(),
        "generator": Path(__file__).relative_to(ROOT).as_posix(),
        "format": "mono signed 16-bit PCM, 22050 Hz",
        "author_acceptance": "Pending CA254-01; technical generation is not a listening approval.",
        "clips": records,
    }
    MANIFEST.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8", newline="\n")
    print(json.dumps(records, indent=2))


if __name__ == "__main__":
    main()

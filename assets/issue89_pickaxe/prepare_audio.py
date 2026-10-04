"""Reproduce issue #89's one-shot chopping sound and unchanged mining OGGs."""
import shutil
import struct
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ORIGINALS = Path(__file__).parent / 'reference_package/audio/originals'
OUTPUT = ROOT / 'src/sounds/caelum/gathering'
OUTPUT.mkdir(parents=True, exist_ok=True)
source = ORIGINALS / 'WOODImpt_Ax on log (ID 0705)_BigSoundBank.com.wav'
# First isolated impact: preserve attack and decay; exclude the next at 2.15 s.
with wave.open(str(source), 'rb') as inp:
    assert (inp.getnchannels(), inp.getsampwidth(), inp.getframerate()) == (1, 2, 48000)
    rate = inp.getframerate()
    inp.setpos(round(0.12 * rate))
    raw = inp.readframes(round(0.78 * rate))
samples = list(struct.unpack('<' + 'h' * (len(raw) // 2), raw))
fade = round(0.004 * rate)
for i in range(fade):
    samples[i] = round(samples[i] * i / fade)
    samples[-1-i] = round(samples[-1-i] * i / fade)
with wave.open(str(OUTPUT / 'chop.wav'), 'wb') as out:
    out.setnchannels(1)
    out.setsampwidth(2)
    out.setframerate(rate)
    out.writeframes(struct.pack('<' + 'h' * len(samples), *samples))
for number, category in [(760565, 'stone'), (760566, 'crystal'), (760567, 'metal')]:
    source = next(ORIGINALS.glob(str(number) + '*.ogg'))
    shutil.copyfile(source, OUTPUT / (category + '.ogg'))
print('Prepared chopping one-shot and three byte-identical mining OGGs.')

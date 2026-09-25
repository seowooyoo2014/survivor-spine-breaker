"""Generate the short voice-like, nonverbal opening sound as a WAV asset."""

import math
import struct
import wave
from pathlib import Path

RATE = 22_050
DURATION = 0.6
OUT = Path(__file__).with_name("voice_bleep.wav")

with wave.open(str(OUT), "wb") as wav:
    wav.setnchannels(1)
    wav.setsampwidth(2)
    wav.setframerate(RATE)
    samples = bytearray()
    for i in range(round(RATE * DURATION)):
        t = i / RATE
        pulse = 1.0 if t % 0.16 < 0.105 else 0.0
        envelope = min(1.0, t * 24.0) * min(1.0, (DURATION - t) * 22.0)
        value = math.sin(2 * math.pi * (145.0 + 32.0 * math.sin(t * 18.0)) * t)
        samples.extend(struct.pack("<h", int(value * 6500 * pulse * envelope)))
    wav.writeframes(samples)

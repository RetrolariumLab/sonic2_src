"""Pure retail S2 PCM, DPCM, PSG-envelope and FM-voice record codecs."""

from scripts.authoring.struct_formats import Codec, keys, uint

DAC_DELTAS = (0, 1, 2, 4, 8, 16, 32, 64, 128, 255, 254, 252, 248, 240, 224, 192)
DAC_CODES = {delta: index for index, delta in enumerate(DAC_DELTAS)}


def decode_dpcm(data):
    value = 128
    result = []
    for byte in data:
        for code in (byte >> 4, byte & 15):
            value = (value + DAC_DELTAS[code]) & 255
            result.append(value)
    return result


def encode_dpcm(samples):
    if len(samples) % 2:
        raise ValueError("DPCM needs an even sample count")
    value = 128
    codes = []
    for sample in samples:
        sample = uint(sample, 8, "PCM sample")
        delta = (sample - value) & 255
        if delta not in DAC_CODES:
            raise ValueError("PCM transition cannot be represented losslessly by the original DPCM table")
        codes.append(DAC_CODES[delta])
        value = sample
    return bytes((codes[i] << 4) | codes[i + 1] for i in range(0, len(codes), 2))


def decode_pcm(data):
    return list(data)


def encode_pcm(samples):
    return bytes(uint(sample, 8, "PCM sample") for sample in samples)


def decode_psg(data):
    try:
        end = data.index(128)
    except ValueError as exc:
        raise ValueError("Missing PSG hold marker") from exc
    return {
        "attenuation_offsets": [value if value < 128 else value - 256 for value in data[:end]],
        "trailer": list(data[end + 1 :]),
    }


def encode_psg(model):
    keys(model, "attenuation_offsets trailer")
    values = []
    for value in model["attenuation_offsets"]:
        if type(value) is not int or not -127 <= value <= 127:
            raise ValueError("PSG attenuation offset collides with hold marker or is outside a signed byte")
        values.append(value & 255)
    return bytes(values) + b"\x80" + bytes(uint(value, 8, "PSG trailing byte") for value in model["trailer"])


# Each operator stays in the driver's register-write order. Reserved bits are
# explicit so that undocumented YM register bits survive a zero-edit cycle.
GROUPS = [
    [("multiple", 0, 4), ("detune", 4, 3), ("reserved", 7, 1)],
    [("attack", 0, 5), ("reserved", 5, 1), ("rate_scale", 6, 2)],
    [("decay_1", 0, 5), ("reserved", 5, 2), ("amplitude_modulation", 7, 1)],
    [("decay_2", 0, 5), ("reserved", 5, 3)],
    [("release", 0, 4), ("sustain_level", 4, 4)],
    [("total_level", 0, 7), ("reserved", 7, 1)],
]
GROUP_NAMES = ["detune_multiple", "attack_rate_scale", "decay_1_am", "decay_2", "sustain_release", "total_level"]


def decode_voices(data):
    if len(data) % 25:
        raise ValueError("Truncated 25-byte FM voice")
    voices = []
    for start in range(0, len(data), 25):
        value = data[start]
        voice = {
            "algorithm": value & 7,
            "feedback": (value >> 3) & 7,
            "reserved": value >> 6,
            "operators": [{} for _ in range(4)],
        }
        for group, (name, fields) in enumerate(zip(GROUP_NAMES, GROUPS)):
            for operator in range(4):
                byte = data[start + 1 + group * 4 + operator]
                voice["operators"][operator][name] = {
                    field: (byte >> shift) & ((1 << width) - 1) for field, shift, width in fields
                }
        voices.append(voice)
    return voices


def encode_voices(voices):
    result = bytearray()
    for voice in voices:
        keys(voice, "algorithm feedback reserved operators")
        if len(voice["operators"]) != 4:
            raise ValueError("FM voice needs four operators")
        result.append(
            uint(voice["algorithm"], 3, "algorithm")
            | (uint(voice["feedback"], 3, "feedback") << 3)
            | (uint(voice["reserved"], 2, "voice reserved") << 6)
        )
        for operator in voice["operators"]:
            keys(operator, " ".join(GROUP_NAMES))
        for name, fields in zip(GROUP_NAMES, GROUPS):
            for operator in voice["operators"]:
                row = operator[name]
                keys(row, " ".join(field for field, _, _ in fields))
                result.append(sum(uint(row[field], width, field) << shift for field, shift, width in fields))
    return bytes(result)


AUDIO_FORMATS = {
    "dpcm-s2": Codec(decode_dpcm, encode_dpcm),
    "pcm-u8": Codec(decode_pcm, encode_pcm),
    "psg-envelope-s2": Codec(decode_psg, encode_psg),
    "fm-voice-s2": Codec(decode_voices, encode_voices),
}

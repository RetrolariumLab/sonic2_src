"""HTZ palette-cycle countdown reloads, exposed as effective frame periods."""


def decode(data):
    if len(data) != 16:
        raise ValueError("HTZ palette cycle needs sixteen timer reloads")
    return [value + 1 for value in data]


def encode(periods):
    if len(periods) != 16:
        raise ValueError("HTZ palette cycle needs sixteen frame periods")
    if any(type(value) is not int or not 1 <= value <= 256 for value in periods):
        raise ValueError("Palette-cycle period must be one through 256 frames")
    return bytes(value - 1 for value in periods)

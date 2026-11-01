"""Content format selection and context-bound serialization for retail inputs."""

import hashlib
from scripts.authoring.struct_formats import Codec, FORMATS, uint
from scripts.authoring.audio_formats import AUDIO_FORMATS
from scripts.authoring import ss_tables, ss_track, smps_s2


def format_id(path):
    if path == "art/kosinski/SpecStag.kos":
        return "special-stage-tile-rows"
    if path.startswith(("art/nemesis/", "art/kosinski/", "art/uncompressed/")):
        return "tiles-4bpp"
    if path.startswith("art/palettes/"):
        return "palette-md"
    if path.startswith("mappings/16x16/"):
        return "blocks-16x16"
    if path.startswith("mappings/128x128/"):
        return "chunks-128x128"
    if path.startswith("mappings/special stage/"):
        return "special-stage-track"
    if path.endswith(".eni"):
        return "tilemap"
    if path.startswith("level/layout/"):
        return "level-layout-s2"
    if path.startswith("level/objects/"):
        return "cnz-bumper-placement" if "bumpers" in path else "object-placement-s2"
    if path.startswith("level/rings/"):
        return "ring-groups-s2"
    if path.startswith("collision/"):
        if path.endswith(".kos"):
            return "collision-index-s2"
        return "collision-heights-s2" if "Collision array" in path else "collision-angles-s2"
    if path.startswith("startpos/"):
        return "start-position-s2"
    if path == "misc/angles.bin":
        return "angle-lookup"
    if path == "misc/sinewave.bin":
        return "sine-lookup"
    if path == "misc/Special stage level layouts.nem":
        return "special-stage-geometry"
    if path == "misc/Special stage object location lists.kos":
        return "special-stage-objects"
    if path == "misc/Special stage object perspective data.kos":
        return "special-stage-perspective"
    if path.startswith("sound/music/"):
        return "smps-music-s2"
    if path.startswith("sound/sfx/"):
        return "smps-sfx-s2"
    if path.startswith("sound/DAC/"):
        return "dpcm-s2"
    if path.startswith("sound/PCM/"):
        return "pcm-u8"
    if path.startswith("sound/psg/"):
        return "psg-envelope-s2"
    if path == "sound/driver.sax":
        return "driver-program"
    raise ValueError("No owned content format: " + path)


def codec(path, context=None):
    context = context or {}
    kind = format_id(path)
    if kind == "chunks-128x128":
        selected = FORMATS[kind]

        def encode_chunks(model):
            if any(entry["index"] >= context["block_capacity"] for chunk in model for entry in chunk):
                raise ValueError("Chunk refers beyond the live block RAM capacity")
            return selected.encode(model)

        return Codec(selected.decode, encode_chunks)
    if kind == "object-placement-s2":
        capacity = context.get("respawn_capacity")
        if type(capacity) is not int or not 0 <= capacity <= 255:
            raise ValueError("Object export requires a canonical respawn RAM capacity")
        selected = FORMATS[kind]
        return Codec(selected.decode, lambda model: selected.encode(model, max_respawn=capacity))
    if kind == "cnz-bumper-placement" and "bumper_order_exception" in context:
        record = context["bumper_order_exception"]
        original = record["stream"]
        if (
            record["asset"] != path
            or type(original) is not bytes
            or hashlib.sha256(original).hexdigest() != record["sha256"]
        ):
            raise ValueError("Preserved bumper stream differs from its reviewed identity")
        selected = FORMATS[kind]
        return Codec(selected.decode, lambda model: selected.encode(model, preserved_stream=original))
    if kind in FORMATS:
        return FORMATS[kind]
    if kind in AUDIO_FORMATS:
        return AUDIO_FORMATS[kind]
    if kind == "special-stage-track":

        def encode_track(model):
            ss_track.render(model, **context["track_lut"])
            return ss_track.encode(model)

        return Codec(ss_track.decode, encode_track)
    if kind == "special-stage-geometry":
        return Codec(ss_tables.decode_geometry, ss_tables.encode_geometry)
    if kind == "special-stage-objects":
        return Codec(
            ss_tables.decode_objects,
            lambda model: ss_tables.encode_objects(model, max_objects_per_group=context["object_slots"]),
        )
    if kind == "special-stage-perspective":
        return Codec(ss_tables.decode_perspective, ss_tables.encode_perspective)
    if kind == "angle-lookup":
        return Codec(ss_tables.decode_angles, ss_tables.encode_angles)
    if kind == "sine-lookup":
        return Codec(ss_tables.decode_sine, ss_tables.encode_sine)
    if kind.startswith("smps-"):
        smps_kind = "music" if kind == "smps-music-s2" else "sfx"
        return Codec(
            lambda data: smps_s2.decode(data, smps_kind, context["base"])[0],
            lambda model: smps_s2.encode(
                model, smps_kind, context["base"], context["external"], context["external_events"]
            ),
        )
    if kind == "driver-program":
        return Codec(lambda data: list(data), lambda values: bytes(uint(value, 8, "driver byte") for value in values))
    raise ValueError("Missing codec for " + kind)

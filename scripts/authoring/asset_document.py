"""Enforce ABI, decoded size and destination capacity before returning asset bytes."""

from dataclasses import dataclass
from scripts.authoring.struct_formats import FORMATS


@dataclass(frozen=True)
class Target:
    asset_id: str
    format_id: str
    abi: str
    address_space: str
    start: int
    encoded_capacity: int
    decoded_capacity: int
    bank_size: int | None = None
    address_limit: int = 0x100000
    fixed_start: bool = True
    protected_ranges: tuple = ()

    def validate(self):
        for name in ["asset_id", "format_id", "abi", "address_space"]:
            if type(getattr(self, name)) is not str or not getattr(self, name):
                raise ValueError("Invalid target " + name)
        if type(self.protected_ranges) is not tuple or any(
            type(pair) is not tuple or len(pair) != 2 for pair in self.protected_ranges
        ):
            raise ValueError("Protected decoded ranges must be immutable pairs")
        for name in ["start", "encoded_capacity", "decoded_capacity", "address_limit"]:
            value = getattr(self, name)
            if type(value) is not int or value < 0:
                raise ValueError("Invalid target " + name)
        if type(self.fixed_start) is not bool or self.start + self.encoded_capacity > self.address_limit:
            raise ValueError("Target slot leaves its address space")
        previous = 0
        for first, last in self.protected_ranges:
            if type(first) is not int or type(last) is not int or not previous <= first < last <= self.decoded_capacity:
                raise ValueError("Protected decoded ranges are invalid or overlap")
            previous = last
        if self.bank_size is not None and (
            type(self.bank_size) is not int or self.bank_size <= 0 or self.bank_size & (self.bank_size - 1)
        ):
            raise ValueError("Bank size must be a positive power of two")


@dataclass(frozen=True)
class Document:
    target: Target
    compression: str
    original_stream: bytes
    original_plain: bytes
    handler: object = None

    @classmethod
    def open(cls, encoded, target, compression="none", decoder=None, handler=None):
        target.validate()
        if handler is None and target.format_id not in FORMATS:
            raise ValueError("Unknown content format")
        selected = handler or FORMATS[target.format_id]
        if compression != "none" and decoder is None:
            raise ValueError("Compressed input needs its decoder")
        plain = bytes(encoded) if compression == "none" else bytes(decoder(bytes(encoded)))
        document = cls(target, compression, bytes(encoded), plain, selected)
        model = selected.decode(plain)
        document.encode(model, target)
        return document, model

    def encode(self, model, target, encoder=None):
        target.validate()
        for field in ["asset_id", "format_id", "abi", "address_space"]:
            if getattr(target, field) != getattr(self.target, field):
                raise ValueError("Content target differs in " + field)
        if (
            target.bank_size != self.target.bank_size
            or target.protected_ranges != self.target.protected_ranges
            or target.fixed_start != self.target.fixed_start
        ):
            raise ValueError("Target changes its bank or protected-layout policy")
        if self.target.fixed_start and target.start != self.target.start:
            raise ValueError("Asset pointers require the original placement start")
        if (
            target.address_limit > self.target.address_limit
            or target.encoded_capacity > self.target.encoded_capacity
            or target.decoded_capacity > self.target.decoded_capacity
        ):
            raise ValueError("Target widens its declared allocation")
        plain = (self.handler or FORMATS[target.format_id]).encode(model)
        for first, last in self.target.protected_ranges:
            if last > len(plain) or plain[first:last] != self.original_plain[first:last]:
                raise ValueError("Edited content changes a protected retail tail or overlap")
        if len(plain) > target.decoded_capacity:
            raise ValueError("Decoded content exceeds its target capacity")
        if plain == self.original_plain:
            result = self.original_stream
        elif self.compression == "none":
            result = plain
        else:
            if encoder is None:
                raise ValueError("Edited compressed content needs its encoder")
            result = bytes(encoder(plain))
        if len(result) > target.encoded_capacity:
            raise ValueError("Encoded content exceeds its original destination slot")
        if target.bank_size is not None and (target.start % target.bank_size) + len(result) > target.bank_size:
            raise ValueError("Encoded content crosses its fixed bank window")
        return result

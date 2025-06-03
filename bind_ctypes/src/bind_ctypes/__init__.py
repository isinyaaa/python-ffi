import ctypes as c
import typing as t
from pathlib import Path

u64 = c.c_uint64
f64 = c.c_double
f64_p = c.POINTER(f64)
Array = tuple[f64_p, u64]


lib = c.CDLL(Path(__file__).parent / "libbind_c.so")
lib.mean.restype = f64
lib.mean.argtypes = [f64_p, u64]
lib.stddev.restype = f64
lib.stddev.argtypes = [f64_p, u64]


def as_f64(ls: t.Iterable[float]) -> t.Iterator[f64]:
    return (f64(v) for v in ls)


def array(vs: t.Iterable[f64], n: int) -> Array:
    return (f64_p((f64 * n)(*vs)), u64(n))


__all__ = [
    "u64",
    "f64",
    "f64_p",
    "Array",
    "array",
    "as_f64",
    "lib",
]

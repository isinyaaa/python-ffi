# /// script
# dependencies = ["cffi"]
# ///
from pathlib import Path
from sys import argv

import cffi

argv = argv[1:]
libname = argv[0].strip()
assert libname, "Expected library name"
header_path = argv[1].strip()
assert header_path, "Expected header path"
src = Path(header_path).resolve().read_text()
ext_path = argv[2].strip()
assert ext_path, "Expected extension path"

ffibuilder = cffi.FFI()
# cdef parser does not support directives
ffibuilder.cdef(
    "\n".join(line for line in src.splitlines() if not line.startswith("#"))
)
ffibuilder.set_source(libname, src)
ffibuilder.emit_c_code(ext_path)

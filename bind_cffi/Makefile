.PHONY: build
build:
	cp -f ../target/release/libbind_c.* src/bind_cffi/
	uv run build.py _rs_stat src/bind_cffi/header.h _cffi.c
	uv build

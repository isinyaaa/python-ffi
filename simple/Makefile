run: py c rs

py:
	@uv run simple.py

c:
	@./simple

rs:
	@../target/release/simple

build:
	clang simple.c -o simple -O2
	cargo build --release


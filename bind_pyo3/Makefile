.PHONY:
build:
	uv build

expand:
	cargo +nightly rustc --profile=check -- -Zunpretty=expanded > expanded.rs

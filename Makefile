repro: clean build bench nb-setup nb

test:
	rm -f values.txt
	./gen -o values.txt -q 1000
	uv run bench.py

bench: .venv gen
	uv pip install benchexec
	rm -f values.txt
	./gen -o values.txt
	@echo 'Run #1'
	@uv run runexec -- uv run bench.py 1
	@cat output.log
	rm -f values.txt
	./gen -o values.txt
	@echo 'Run #2'
	@uv run runexec -- uv run bench.py 2
	@cat output.log
	rm -f values.txt
	./gen -o values.txt
	@echo 'Run #3'
	@uv run runexec -- uv run bench.py 3
	@cat output.log

build: build-generator .venv
	cargo build --release -p bind_c
	cd bind_cffi && make
	cd bind_ctypes && make
	uv pip install numpy ./bind_c ./bind_cffi ./bind_ctypes ./bind_pyo3

.venv:
	uv venv -p 3.12 --seed

nb-setup: .venv
	uv pip install jupyterlab matplotlib

nb: .venv
	uv run jupyter execute plots.ipynb

nb-server: .venv
	uv run jupyter lab

build-generator: gen
gen:
	odin build gen.odin -file -o:speed

clean:
	cargo clean
	rm -rf values.txt gen .venv results output.files *.pdf plots/*

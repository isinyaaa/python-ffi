test:
	rm values.txt
	./gen -o values.txt -q 1000
	uv run bench.py

bench: .venv gen
	uv pip install benchexec
	rm values.txt
	./gen -o values.txt
	@echo 'Run #1'
	@uv run runexec -- uv run bench.py 1
	@cat output.log
	rm values.txt
	./gen -o values.txt
	@echo 'Run #2'
	@uv run runexec -- uv run bench.py 2
	@cat output.log
	rm values.txt
	./gen -o values.txt
	@echo 'Run #3'
	@uv run runexec -- uv run bench.py 3
	@cat output.log

build: build-generator .venv
	cargo build --release
	cd bind_cffi && make
	cd bind_ctypes && make
	cd bind_pyo3 && make
	uv pip install numpy ./bind_c ./bind_cffi ./bind_ctypes ./bind_pyo3

.venv:
	uv venv -p 3.12 --seed

nb:
	uv pip install jupyterlab matplotlib
	uv run jupyter lab

build-generator: gen
gen:
	odin build gen.odin -file -o:speed

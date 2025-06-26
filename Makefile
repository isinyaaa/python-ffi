repro: clean build bench nb-setup nb

UNAME_S := $()

# Linux
ifeq ($(shell uname -s),Linux)
    CMD := uv run runexec --
	POST := cat output.log
else
    CMD := 
	POST := mkdir output.files; cp -r results output.files/
endif

test:
	rm -f values.txt
	./gen -o values.txt -q 1000
	uv run bench.py

bench: .venv gen
	uv pip install benchexec
	rm -f values.txt
	./gen -o values.txt
	@echo 'Run #1'
	@${CMD} uv run bench.py 1
	@${POST}
	rm -f values.txt
	./gen -o values.txt
	@echo 'Run #2'
	@${CMD} uv run bench.py 2
	@${POST}
	rm -f values.txt
	./gen -o values.txt
	@echo 'Run #3'
	@${CMD} uv run bench.py 3
	@${POST}

build: build-generator .venv
	cargo build --release -p bind_c
	cd bind_cffi && make
	cd bind_ctypes && make
	# cd bind_pyo3 && make
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

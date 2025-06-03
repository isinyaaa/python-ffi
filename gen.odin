package main

import "core:bytes"
import "core:flags"
import "core:fmt"
import "core:io"
import "core:math/rand"
import "core:os"
import "core:slice"

QTY :: 1_000_000
MAX :: 100_000_000

Arguments :: struct {
	min:  int `args:"name=m" usage:"min value in range"`,
	max:  int `args:"name=M" usage:"max value in range"`,
	qty:  int `args:"name=q" usage:"values to generate"`,
	seed: u64 `args:"name=s" usage:"rng seed"`,
	out:  string `args:"name=o" usage:"output, defaults to stdout"`,
}


main :: proc() {
	args := Arguments {
		min  = 1,
		max  = MAX,
		qty  = QTY,
		seed = 0xdeadbeef,
	}
	assert(flags.parse(&args, os.args[1:], .Unix) == nil)
	rng := rand.create(args.seed)

	values := make([]int, args.qty)
	{
		range := args.max - args.min
		for i in 0 ..< args.qty do values[i] = rand.int_max(range) + args.min
	}
	{
		f: os.Handle
		if len(args.out) != 0 {
			err: os.Error
			f, err = os.open(args.out, os.O_CREATE | os.O_WRONLY, 0o644)
			if err != nil do fmt.panicf("Error opening %v: %v", args.out, err)
		} else {
			f = os.stdout
		}
		out := io.to_writer(os.stream_from_handle(f))
		e: io.Error
		for v in values {
			_, e = io.write_int(out, v)
			assert(e == nil)
			_, e = io.write_rune(out, '\n')
			assert(e == nil)
		}
		io.flush(out)
	}
}

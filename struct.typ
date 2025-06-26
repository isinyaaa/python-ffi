#import "@preview/cetz:0.4.0"

#let unaligned(len) = cetz.canvas(length: len, {
	import cetz.draw: *

	grid((-1,-4), (8,0), help-lines: true)
	let byte = 1
	rect((-1, -1), (rel: (byte, byte)), name: "bit", stroke: (dash: "dotted"))
	content((rel:(0,0), to:"bit.center"),
		// anchor: "center",
		box(fill: white, inset: 1pt, [1B])
	)
	// content((rel:(-2pt,0), to:"bit.south"),
	// 	anchor: "north",
	// 	align(center,
	// 	box(width: 4em, fill: white, inset: 1pt, [machine address alignment]))
	// )

	let word = 8
	let gap = 0.1
	let indent = 0.5
	line((0, .5), (rel: (word, 0)),
		name: "def",
		mark: (symbol: "straight")
	)
	content(("def.start", 50%, "def.end"),
		box(fill: white, inset: 1pt, [64b = 8B])
	)
	content((rel:(gap,0), to:"def.end"),
		anchor: "west", [`struct data_t {`]
	)

	rect((0, 0), (rel: (word, -1)), name: "l1")
	line("def.start", "l1.north-west",
		stroke: (dash: "dashed")
	)
	line("def.end", "l1.north-east",
		stroke: (dash: "dashed")
	)
	content((rel:(gap + indent,0), to:"l1.east"),
		anchor: "west",
		text(red)[`bool b;`]
	)
	rect((rel:(0,0),to: "l1.start"), (rel: (1, -1)),
		name: "m1",
		fill: red,
		style: (inset: 1pt)
	)
	content((rel:(0,0), to:"m1"),
		anchor: "center",
		[`b`]
	)
	content((rel:(2pt,0), to:"l1.south-east"),
		anchor: "west",
		box(fill: white, inset: 1pt, text(0.8em)[8B])
	)

	rect((0, -1), (rel: (word, -1)),
		name: "l2"
	)
	content((rel:(gap + indent,0), to:("l2.east")),
		anchor: "west",
		text(teal)[`int64_t i;`]
	)
	rect((rel:(0,0),to: "l2.start"), (rel: (word, -1)),
		name: "m2",
		fill: teal,
		style: (inset: 1pt)
	)
	content((rel:(0,0), to:"m2"),
		anchor: "center",
		[`i`]
	)
	content((rel:(2pt,0), to:"l2.south-east"),
		anchor: "west",
		box(fill: white, inset: 1pt, text(0.8em)[16B])
	)

	rect((0, -2), (rel: (word, -1)), name: "l3")
	content((rel:(gap + indent,0), to:("l3.east")),
		anchor: "west",
    {
		text(olive)[`uint16_t u;`]
        // v(2pt)
		text(orange)[`char c;`]
    }
	)
	rect((rel:(0,0),to: "l3.start"), (rel: (1/4 * word, -1)),
		name: "m3",
		fill: olive,
		style: (inset: 1pt)
	)
	content((rel:(0,0), to:"m3"),
		anchor: "center",
		[`u`]
	)
	rect((rel:(0,0),to: "m3.north-east"), (rel: (1, -1)),
		name: "m3b",
		fill: orange,
		style: (inset: 1pt)
	)
	content((rel:(0,0), to:"m3b"),
		anchor: "center",
		[`c`]
	)
	content((rel:(2pt,0), to:"l3.south-east"),
		anchor: "west",
		box(fill: white, inset: 1pt, text(0.8em)[24B])
	)

	rect((0, -3), (rel: (word, -1)),
		name: "l4"
	)
	content((rel:(gap + indent,0), to:("l4.east")),
		anchor: "west",
		{
			text(purple)[`char* cs;`]
			[` };`]
		}
	)
	rect((rel:(0,0),to: "l4.start"), (rel: (word, -1)),
		name: "m4",
		fill: purple,
		style: (inset: 1pt)
	)
	content((rel:(0,0), to:"m4"),
		anchor: "center",
		[`cs`]
	)
	content((rel:(2pt,0), to:"l4.south-east"),
		anchor: "west",
		box(fill: white, inset: 1pt, text(0.8em)[32B])
	)
})

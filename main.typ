#import "ieee.typ": *
// #import "@preview/timeliney:0.2.0"
// #import "@preview/big-todo:0.2.0": *
#import "struct.typ": *


#let todo(body, inline: false, big_text: 40pt, small_text: 15pt, gap: 2mm) = []
#let linkref(url, txt) = {
    link(url)[#txt]
    footnote(link(url)[#url])
}

#show: ieee.with(
    // font: "Palatino",
    // fontsize: 10pt,
    title: [Evaluating the PyO3 bindings toolchain for accelerating Python],
    authors: (
        (
            name: "Isabella Basso do Amaral",
            department: [
                Molecular Sciences \
                University of São Paulo
            ],
            email: "isabellabdoamaral@usp.br",
        ),
        (
            name: "Alfredo Goldman",
            department: [
                Mathematics and Statistics Institute (IME) \
                University of São Paulo
            ],
            email: "gold@ime.usp",
        ),
        (
            name: "Renato Cordeiro Ferreira",
            department: [
                Mathematics and Statistics Institute (IME) \
                University of São Paulo
            ],
            email: "renatocf@ime.usp",
        ),
    ),
    // date: datetime.today().display(),
    abstract: [
    The Python programming language is best known for its syntax and scientific libraries, but it is also notorious for
    its incredibly slow interpreter.
    Optimizing critical sections in Python entails special knowledge of the binary interactions between programming
    languages, and can be cumbersome to interface manually, with implementers often resorting to convoluted third-party
    libraries.
    This comparative study evaluates the performance and ease of use of the PyO3 Python bindings toolchain for Rust
    against ctypes and cffi.
    By using Rust tooling developed for Python we are able to achieve state-of-the-art performance with no concern for
    API compatibility.
    ],
    index-terms: ([FFI], [Rust], [Python], [NumPy], [benchmarking], [scientific computing], [numerical methods]),
    // acknowledgments: "This paper is a work in progress. Please do not cite without permission.",
    // bibliography: ,
    // draft: false,
)

// #outline()

// #set text(spacing: 50%)

// #todo_outline

= Introduction

The Python programming language @python has been thoroughly used in industry and academia, however due to its slow interpreter
it serves mostly as glue for lower-level libraries that perform useful algorithms.
While there are methods for accelerating Python programs in Python, due to its high-level abstractions the language
cannot take the slightest advantage of machine resources.

Considering the Pythonic `sum` function, for example, a simple benchmark against a poor man's C implementation (shown
in @code:c-sum) yields a 30x slowdown.
While the Python `sum` can be easily remedied with the array programming package NumPy @numpy, NumPy itself must be
implemented in C to yield its performance.

#figure(
    caption: [C implementation of integer sum],
    placement: auto,
```C
static uint64_t sum_list(uint64_t *list, uint64_t n) {
    uint64_t total = 0;
    for (uint64_t i = 0; i < n; i++) {
        total += list[i];
    }
    return total;
}
```
) <code:c-sum>

Known primarily for its speed, the C programming language @kernighan1988c has defined the standard binary interface for
bindings due to its prevalence, and has been traditionally used for creating universal software packages at the
cost of developer sanity, having outstanding undefined behavior issues @undefined which prompted generations of
additional tooling to remedy many of its design faults.
However, in recent years there emerged a variety of systems programming languages that have learned from C and can also
deliver its performance, as they are built using modern tooling for C, namely the LLVM toolchain @lattner2004llvm.
The Rust programming language @rust has become a common alternative to C, and takes pride on its _zero-cost_ abstractions
making it very expressive for all tastes of programmers.
A benchmark illustrates the performance parity of the chain `iter().sum()`#footnote[
    Provided by the `std::iter::Sum` trait.
] with NumPy's `ndarray.sum()` and
@code:c-sum against the slow Python `sum` for a hundred million integers, with results shown on @tab:toy-bench.

#figure(
    caption: [Benchmark results for taking the sum of $10^8$ integers.
    Executed using CPython 3.12.8, NumPy 2.2.0, Rust 1.87.0 on Linux 6.14.19 with a Ryzen 7 5800X CPU.
    Execution time is shown as average with standard deviation for 10 executions.
],
    placement: auto,
    table(
        align: center + horizon,
        columns: (auto, auto),
        stroke: (top: 0.5pt, bottom: 1pt, left: 0pt, right: 0pt),
        table.header(
            [Implementation],
            [time (ms)],
        ),
        [ Python #linkref("https://docs.python.org/3/library/functions.html#sum", `sum`) ], [ 618 $plus.minus$ 3.1 ],
        [ NumPy `sum`#footnote[The implementation first converts the array into a NumPy array for fairness.]#footnote[#link("https://numpy.org/doc/stable/reference/generated/numpy.sum.html")[numpy.org/doc/stable/reference/generated/numpy.sum.html]] ], [ 24 $plus.minus$ 0.2 ],
        link(<code:c-sum>)[ C ], [ 23.0 $plus.minus$ 0.01 ],
        [ Rust `iter().sum()`#footnote[Described on #link("https://doc.rust-lang.org/std/iter/trait.Sum.html")[doc.rust-lang.org/std/iter/trait.Sum.html].] ], [ 23.1 $plus.minus$ 0.02 ],
    )
) <tab:toy-bench>

This study *evaluates modern tooling alternatives accelerate Python, with respect to both performance and ease of use*.
Starting from the ground up in @chap:bind, then introducing methods on @chap:method.
@chap:design discusses Python FFI mechanisms as well as candidate approaches, with the rest of this study
dedicated to benchmarks and their analysis on @chap:bench and @chap:analysis, respectively.

== Research gap

@tab:reviewed-papers summarizes reviewed papers that attempt to improve the performance of Python programs using Rust bindings.
They were aggregated through Google Scholar search using the keywords "Python", "bindings", "performance", "FFI" and "benchmark".
Only papers that include benchmark results have been kept, leaving 5 papers for analysis.
Out of those, #cite(<schofield2024benchmark>, form: "prose") is considered irreproducible as the authors omit all
relevant listings and do not provide source code.

#cite(<van2024simplifying>, form: "prose") discusses some implementation details regarding their use of bindings for
Python, and have abandoned PyO3 for the lack of automatic interface definitions in favor of a domain-specific solution, however they do not discuss relevant implementation for those bindings.
The remaining papers do not discuss the bindings implementations even though they use PyO3.
As such, no reviewed paper demonstrates the reasoning or implementation of those bindings, also lacking a complete
discussion of bindings strategies which can be suboptimal.

#figure(
    caption: [Research papers reviewed in this study.],
    placement: auto,
    table(
        align: center + horizon,
        columns: (auto, auto, auto),
        stroke: (top: 0.5pt, bottom: 1pt, left: 0pt, right: 0pt),
        table.header(
            [Paper], [Benchmark methods], [Source]
        ),
        cite(<teschner2025rustims>, form: "full"),
        [
            Execution time against equivalent tool
        ],
        link("https://github.com/theGreatHerrLebert/rustims")[github.com/theGreatHerrLebert/rustims],
        cite(<van2024simplifying>, form: "full"),
        [
            Execution time against equivalent tool
        ],
        link("https://github.com/chvanam/fdp-rust-manifest")[github.com/chvanam/fdp-rust-manifest],
        cite(<kusters2024developing>, form: "full"),
        [
            Execution time on domain-specific standard benchmark
        ],
        link("https://github.com/aarkue/rust4pm")[github.com/aarkue/rust4pm],
        cite(<schubert2022medoids>, form: "full"),
        [
            Execution time on MNIST sample
        ],
        link("https://github.com/kno10/rust-kmedoids")[github.com/kno10/rust-kmedoids],
        cite(<schofield2024benchmark>, form: "full"),
        [
            Execution time
        ],
        [Unavailable],
    )
) <tab:reviewed-papers>

== Reproducibility concern <sec:repro>

Research software plays a pivotal role in the industry, but it is not held at high enough standards, or at least not
comparable to more traditional research methods.
It is often developed by researchers with neither training nor real world development experience and, as such, its
long-term sustainability is compromised @carver2022survey.
#cite(<lenarduzzi2017analyzing>, form: "prose") note the near impossible replication of many software studies,
characterized as a common occurrence.

One particular development strategy that appeals to modern scientific standards is that of open source, in which the
source code is available to users.
Notably, as open-source software is auditable, it becomes easier to verify reproducibility @barba2022defining.
This also allows for early collaboration between researchers and developers, which can lead to better software design
and performance @wilson2014best.
Building on the practice of open source we also have _free software_ (commonly denoted by FLOSS or FOSS): a development
ideology centered on volunteer work and donations, and that is permissively (_copyleft_) licensed.
There is emerging work on the role of FLOSS in science, such as #cite(<fortunato2021case>, form: "prose"), and some
initiatives which praise a similar approach @katz2018community, @barker2022introducing.

This study is dedicated to the open source community as an effort to promote better software that can be used
as a foundation for research.
All listings and the full experimental setup can be obtained at #link("https://github.com/isinyaaa/python-ffi")[github.com/isinyaaa/python-ffi].

== Research question <sec:quest>

We evaluate the feasibility of working consistently in a hybrid-language workflow, enabling high-performance Python
through foreign function interfaces (FFI) to systems programming languages.
This has traditionally been done using the C programming language, which can pose great challenges to program
correctness.
We start our exploration by comparing alternative ways to interact with Python, evaluating each with respect to both
*performance* and *_Developer eXperience_ (DX)*.

In order to properly characterize DX as it relates to ease of use, we draw inspiration from #cite(<moseley2006out>, form: "prose") to differentiate between _essential_ and _accidental_
complexity.
We can briefly illustrate their difference by studying a simple solution to the infamous "URL shortener" problem which,
on a high level, only requires an _essential_ (and trivial) record of the shortened URL to its full counterpart.
This tragic problem in truth only exists because of the complexities of the real world, for now take the requirement
that it stays available (online) indefinitely, and the solution has to contort with _accidental_ complexity to ensure
e.g. restarting does not corrupt previous records.

We evaluate the implementations according to two DX criteria and one performance criterion#footnote[We omit memory usage measurements due to limitations in our experimental setup.] that we believe drive technology adoption, namely:

+ *RQ1* Implementation conciseness #label("obj:accident")

    _What is the accidental complexity of the implementation?_
+ *RQ2* Gaps in tooling #label("obj:tool")

    _How laborious is the setup e.g. in order to ensure proper functioning?_
+ *RQ3* Execution time against standard options #label("obj:speed")

    _How faster is it than NumPy?_

#show "obj1": link(<obj:accident>)[RQ1 (conciseness)]
#show "obj2": link(<obj:tool>)[RQ2 (gaps in tooling)]
#show "obj3": link(<obj:speed>)[RQ3 (speed)]

// #colbreak()

= Bindings <chap:bind>

Each programming language abstracts machine primitives in a different way, and expects specific binary layouts for each
procedure invocation.
A common binary interface is necessary when interoperating across programming languages, requiring conversions which
can also be costly.
Such exports are technically known as _foreign function interfaces_ (FFI), and commonly known as _bindings_.

== C ABI

It is common practice to use the C ABI (Application Binary Interface) _lingua franca_ as the binary interface between languages, requiring a
register-based calling convention (i.e. using hardware registers as opposed to stack values) and word-sized memory
alignment, demonstrated in @fig:struct-pad.
Those can be easily attained in most compiled languages, including Rust.
Linking the exported functions depends on the circumstances, requiring a special treatment for Python.
// Connecting the implementation with the host language is usually the main issue, discussed throughout this chapter.

#figure(
    caption: [C struct padding#footnote[
Note that one has to `#include <stdbool.h>` in order to use `bool`, and we also `#include <stdint.h>` to use fixed sized integer types.
    ].
    The dotted square denotes the machine address alignment corresponding to 1 byte.
    The `struct data_t` has five fields with different data types.
    Note that even after padding the `bool` with 7 bits the C compiler will not let `int64_t i` overflow beyond
    word-alignment, and we end up with 63 bits of padding for a single used bit.
    Moreover, note that a pointer will always occupy an entire word, so there is another padding after our `char c` field.
],
    placement: auto,
    unaligned(0.6cm)
) <fig:struct-pad>

== Compiling and linking

Labelled memory locations such as functions and globals are known as _symbols_ when treating compiled artifacts.
When exported by the compiler those symbols are available in the _symbol table_ for external linkage in the resulting binary object blob and
can be reused.
It is most common to rely on a linker to resolve those symbols during compilation, however it is desirable to avoid
recompiling the Python interpreter, as such _dynamic loading_ is the most common method for bindings.
Dynamic loading requires using _shared_ objects, and instead of compiling those objects it is possible to invoke the
`dlopen` and `dlsym` system calls, which are used to open the object, then find a specific symbol, respectively.
Usually symbols are known by the implementer but they can also be dynamically resolved using _libffi_.

== Python bindings alternatives <sec:pybind>

Python has supported dynamic symbol resolution through the
#linkref("https://docs.python.org/3/library/ctypes.html", [ctypes library]), however it may be desirable to manipulate
Python objects which is supported through #linkref("https://docs.python.org/3/extending/extending.html", [extension modules]).
They are implemented by compiling a shared library that defines standard symbols recognized by the Python interpreter,
which can be parsed upon dynamic loading and expose Python-native types and functions.

The #linkref("https://cffi.readthedocs.io/en/stable/", [cffi library]) allows users to generate Python bindings given the C function signatures automatically.
This is the low-level functionality provided by the PyO3 toolchain @johnson2024pyo3, which integrates with Rust to
provide better developer experience.
The underlying implementation depends on the #linkref("https://www.maturin.rs/", [Maturin]) build system for Python, which integrates with the Rust build
system#footnote[Cargo: #link("https://doc.rust-lang.org/cargo/")[doc.rust-lang.org/cargo/]] and can build and link extension modules, replacing the traditional #linkref("https://setuptools.pypa.io/en/latest/setuptools.html", [setuptools]).

== Bindings performance <sec:bindperf>

There are primarily two methods for exposing data through bindings:
+ *M1* In-situ conversion #label("bind:situ")

    Arguments and return values are converted upon function invocation, usually through glue code (not entirely implemented by the user).
    This is not necessarily a pass-by-value approach as Python dicts and lists still use references and require proper handling.

+ *M2* Specialized constructors #label("bind:pointer")

    Exposes specialized opaque containers that impose the actual memory boundaries between implementations on the API.
    Values must be passed by pointer to the opaque struct/class.

The two approaches may be viable depending on the constraints, and are accepted in NumPy interfaces, however
specialized constructors are the preferred approach because of the wild difference in binary representation between
Python and compiled languages.

#show "api1": link(<bind:situ>)[M1 (in-situ)]
#show "api2": link(<bind:pointer>)[M2 (constructor)]

// #colbreak()

= Methodology <chap:method>

In order to answer our research questions we evaluate the three bindings methods described on @sec:pybind, namely ctypes, cffi, and PyO3 on the same underlying Rust implementation of simple mathematical procedures that are known for
poor performance in Python and are present in NumPy.

The ease of use aspects (DX) are evaluated as:
obj1 based on the attained implementations regarding their
expressiveness on exposing the functionality;
obj2 during the implementation, based on missing functionality
that is required by bindings users.

// In order to properly compete with C we chose to use the Rust programming language, which is often compared to C++ due
// to its extensive feature set.

The performance aspect will be evaluated under obj3 following the main concern laid out in @sec:bindperf:
in short, because of the heterogeneous Python binary representation crossing over the C ABI poses several design challenges to
enable any kind of flexibility, often expected in Python-native interfaces such as NumPy.

The primary goal of the implementations is at minimizing those conversions, as such there are two implemented versions
of each following api1 and api2.
We start by comparing the two API approaches with the reference in a standard batched approach to present expected
overheads for a single procedure call.
We then break up our sample in homogeneous chunks, evaluating function call overhead between our main candidates by
accumulating the batched execution times for the entire sample.
This allows us to estimate the actual calculation run time as the lower bound of our graph, then estimate the function call overhead in relation to frequency.
Finally, we perform a linear regression to find the overhead by call.

// #colbreak()

= Implementation <chap:design>

To prove Rust's usefulness as a C replacement we expect reasonable performance for two elementary statistics
functions, namely the *arithmetic mean*
(#link("https://numpy.org/doc/2.2/reference/generated/numpy.mean.html")[`numpy.mean`]) and *population standard
deviation* (#link("https://numpy.org/doc/stable/reference/generated/numpy.std.html")[`numpy.std`]).

The base implementation for the arithmetic mean and population standard deviation follow the respective mathematical formulas:

$ overline(x)(X) = sum_(x in X) x / (\#X) $ <math:mean>
$ sigma(X) = sqrt(sum_(x in X) (x - overline(x))^2 / (\#X)) $ <math:std>

Note that NumPy allows the user to define a denominator offset for the variance calculation in order to enable
evaluating the sample standard deviation.
It also implements its own array types, overloading operators to behave linearly (i.e. operations are performed element-wise),
which allows for trivial extension of the arithmetic mean to evaluate the expected value of a distribution.
We will not attempt at providing flexible interfaces or operator overloads, assuming a minimalistic use-case of those
two functions, which is separated into a `statistics` crate and reused as `stat`, shown in @code:rs-stat.

#figure(
    caption: [
    Rust implementations for mean and standard deviation.
    The functions receive a reference to a slice, which is an abstraction over a pointer to an array that also
    includes its size.
    A reference does not need _ownership_ and so those functions only _borrow_ the array#footnote[
        In Rust's memory model the _owner_ will assume responsibility for the value and _drop_ it at the end of the
        scope, freeing its memory.
        This is not the case when borrowing a value which only takes in a reference to it.
    ].
],
    placement: auto,
    ```rs
fn mean(values: &[f64]) -> f64 {
    values.into_iter().sum::<f64>() / (values.len() as f64)
}

fn stddev(values: &[f64]) -> f64 {
    let m = mean(&values);
    let mut squared_sum = 0.0;
    for v in values {
        let shifted = v - m;
        squared_sum += shifted * shifted;
    }
    (squared_sum / (values.len() as f64)).sqrt()
}
    ```
) <code:rs-stat>

== Traditional bindings methods

By exporting the Rust API we can utilize the traditional bindings methods using ctypes and cffi which are implemented
in Python, being the standard options for Python programmers.
This scenario is most useful when the low-level implementation source is not available, but only binaries and the API declaration as a header.

We declare a separate crate for our C bindings, as it requires different compilation targets.
In order to create a shared library in Rust we must declare the option `lib.crate-type = ["cdylib"]` in `Cargo.toml`#footnote[
    We assume that all Rust projects use Cargo.
].
For each exported function we add `#[unsafe(no_mangle)]` to avoid using Rust-specific symbols, and also declare that we
would like to specifically use the C calling convention with `extern "C"` in the function signature, as demonstrated in
@code:rsc.

#figure(
    caption: [
    Rust FFI code for interacting with C.
    `pointer_to_vec` is defined as a generic (parametric) function to enable easy reuse for other sequence types.
],
    placement: auto,
```rs
use statistics as stat;

// <T: Clone> (generic) parameter:
//    defines a parametric constant (type) which specializes the implementation at compile time.
//    `Clone` specifies that the type can be copied recursively (following pointers).
// unsafe:
//    is necessary as the `std::slice::from_raw_parts` reinterprets memory, which might lead to undefined behavior if
//    the programmer specification is wrong (e.g. actual size != n).
fn pointer_to_vec<T: Clone>(values: *mut T, n: u64) -> Vec<T> {
    unsafe { std::slice::from_raw_parts(values, n as usize) }.into()
}

#[unsafe(no_mangle)]
pub extern "C" fn mean(values: *mut f64, n: u64) -> f64 {
    // dereferencing a Vec yields a slice by default
    stat::mean(&pointer_to_vec(values, n))
}

#[unsafe(no_mangle)]
pub extern "C" fn stddev(values: *mut f64, n: u64) -> f64 {
    stat::stddev(&pointer_to_vec(values, n))
}
```
) <code:rsc>

Note that to interface with C we need to _cast_ memory, that is, reinterpret it appropriately into a native Rust type,
as demonstrated in the `pointer_to_vec` helper.
Because the lifetime of the original memory is not clear, we must copy it in Rust to avoid a double-free.
Rust requires using unsafe blocks in order to communicate possible undefined behavior, however such an abstraction does
not prevent undefined behavior from occurring, as any caller might pass in $n > "len"("values")$ thus provoking a
buffer overflow, much similar to our `sum` function in the introductory C example @code:c-sum.
It might be preferable to omit the helper entirely or mark it as `unsafe` but this is not required.
In common practice it is very undesirable to use unsafe APIs due to the increase in boilerplate and additional mental
overhead to ensure correctness which can be greatly reduced by limiting programs to safe Rust.

== Binding with ctypes <sec:ctypes>

// Off the start we already face portability issues as each operating system will compile with different extensions, and
// this needs to be specified when providing bindings.
// On Windows, for instance, shared libraries will compile to .dll, and on Darwin (macOS) they will be compiled to .dylib.
// In our case, we are only concerned with Linux, so we use .so extensions for our examples.

@code:py-ctypes shows a minimalistic module initialization example for our API.
The instance must be initialized with the path to the shared library, and can be used immediately (i.e. it can be
scripted).
For this, we will convert each `float` instance to a `ctypes.c_double` (aliased as `f64`), then to allocate memory we
use ctypes array constructor syntax, in which we take the product of the type (representing its size) by the array
length, getting a new constructor for that specific size.
The `c.POINTER` helper function creates a pointer constructor for the specified type, which takes our buffer (array) and produces a Pythonic wrapper for the pointer.
We wrap the array pointer with its size into a synthetic `Array` tuple that is only used for typing.
Note that all boilerplate functions could be abstracted to work over polymorphic types -- e.g. see the #link("https://catt.rs/en/stable/index.html")[catt.rs: Flexible Object Serialization and Validation] for a library implementation of a converter framework.

#figure(
    caption: [
    Python ctypes code for exposing the statistics API.
    We use _iterators_#footnote[
        An iterator abstracts sequential access of a data structure.
    ] to allow for lazy construction, alleviating the need to create the float values twice.
],
    placement: auto,
```py
import ctypes as c
import typing as t
from pathlib import Path

u64 = c.c_uint64
f64 = c.c_double
f64_p = c.POINTER(f64)
Array = tuple[f64_p, u64]


lib = c.CDLL(Path(__file__).parent / "target/release/libbind_c.so")
lib.mean.restype = f64
lib.mean.argtypes = [f64_p, u64]
lib.stddev.restype = f64
lib.stddev.argtypes = [f64_p, u64]


def as_f64(ls: t.Iterable[float]) -> t.Iterator[f64]:
    return (f64(v) for v in ls)


def array(vs: t.Iterable[f64], n: int) -> Array:
    return (f64_p((f64 * n)(*vs)), u64(n))
```
) <code:py-ctypes>

== Classic cffi bindings <sec:cffi>

Using cffi in its intended use case we need to define a header file for our public interface as shown on @code:h, which is common
practice when
providing FFI bindings#footnote[
    Because header files are ubiquitous when declaring C APIs while also acting as documentation.
].
Fortunately cffi allows us to use a static library, which we can easily get by adding `staticlib` to our `lib.crate-type`
config array.
This allows us to simplify the setup as the library only needs to be present during the project build step, and not
when executing.

#figure(
    caption: [Library header exposing statistics functions.],
    placement: auto,
```c
#include <stdint.h>
#include <stdlib.h>

double mean(double *values, uint64_t n);
double stddev(double *values, uint64_t n);
```
) <code:h>

We need to define a small script with the C API that also references the header file, as well as the compiled binary, as shown on @code:cffi.
// Unfortunately cffi is coupled to the setuptools build system and does not document any ways to execute code, with
// users relying on configuration snippets.
The cffi setuptools integration works by compiling (i.e. executing the script with `FFI.compile()`) the source using distutils, which is distributed with setuptools.
However, it is possible to generate the extension module wrapper code independently of setuptools (using
`FFI.emit_c_code()`), as shown on @code:cffi, which also enables swapping the build system entirely.
// We will stick to setuptools to avoid introducing other build systems such as Meson or CMake unnecessarily.

#figure(
    caption: [Python cffi code for exposing the statistics API.],
    placement: auto,
```py
import cffi

ffibuilder = cffi.FFI()
ffibuilder.cdef("""
double mean(double *values, uint64_t n);
double stddev(double *values, uint64_t n);
""")
ffibuilder.set_source(
    "_rs_stat",
    """
        #include "header.h"
    """,
    #libraries=["rs_stat"],  # unnecessary for standalone purposes
)

if __name__ == "__main__":
    # setuptools integration
    #ffibuilder.compile()

    # standalone script
    ffibuilder.emit_c_code()
```
) <code:cffi>

Note that in order to use the bindings it is still necessary to compile the generated extension module.
Using setuptools requires us to package the Rust shared object file as well as our header, then specify the desired
linking setup used for the extension, shown on @code:setuptools-ext.
//  and this approach also allows us to link the Rust
// library statically to our bindings.

#figure(
    caption: [Setuptools build system setup on pyproject.toml.],
    placement: auto,
```toml
[build-system]
requires = ["setuptools"]
build-backend = "setuptools.build_meta"

[tool.setuptools]
ext-modules = [
    { name = "_rs_stat", sources = [
        "_cffi.c",
    ], libraries = [
        "bind_c",
    ], library-dirs = [
        "src/bind_cffi",
    ]},
]
packages.find.where = ["src"]
package-data.traditional = ["*.h", "target/release/*.a"]
```
) <code:setuptools-ext>

After compiling the extension we can invoke the `mean` and `std` functions by importing `lib` from the compiled `_rs_stat` module.
The extension has built-in type conversion glue code, which is standard for modern FFI generation tools.
This adds invisible overhead when calling those functions, as the C type conversions take place and allocate memory for
the array every time each function is called, as described in api1.
// We will label this API approach as _consistent_, as it preserves the C API usage and provides a consistent memory view
// on the data for both parties.

A common technique to address this is to wrap values in custom types and export constructors, as described in api2,
implemented in @code:rsc-array and exported as @code:h-array.
Note that this approach may fail to provide a consistent memory view on the latest values if the type contents (either `struct` or `class` members) are altered in either implementation after construction.
// We will label this API approach as _pointer-based_, as it is most common to then use opaque `structs` for most operations, with
// no public members, held as pointers on Python.
// This variant will be tested alongside the basic function bindings to confirm the overhead.

#figure(
    caption: [
    Library header exposing a proto-class through an opaque `struct`.
    Methods will be prefixed with the record name to follow the C API conventions (unrelated to calling convention).
],
    placement: auto,
```c
struct Array;

struct Array *array_init(double *, uint64_t);
double array_mean(struct Array *);
double array_stddev(struct Array *);
```
) <code:h-array>

#figure(
    caption: [Rust FFI code exposing a synthetic array. `Vec` is a dynamically allocated list which is necessary to make our array `Sized` (i.e. fixed size) even though the internal buffer size cannot be determined.],
    placement: auto,
```rs
#[repr(C)]
pub struct Array(Vec<f64>);

#[unsafe(no_mangle)]
pub extern "C" fn array_init(values: *mut f64, n: u64) -> *const Array {
    let boxed = Box::new(Array(pointer_to_vec(values, n)));
    Box::into_raw(boxed)
}

#[unsafe(no_mangle)]
pub extern "C" fn array_mean(arr: *mut Array) -> f64 {
    mean(&unsafe { &*arr }.0)
}

#[unsafe(no_mangle)]
pub extern "C" fn array_stddev(arr: *mut Array) -> f64 {
    std(&unsafe { &*arr }.0)
}
```
) <code:rsc-array>

== Maturin build system

// Having a Rust implementation allows us to use the maturin build system.
The maturin CLI tool provides an interactive setup experience, however we still document its behavior for
reproducibility purposes.

To use maturin we must define it as our build system in pyproject.toml, demonstrated in @code:maturin-bs.
We also need a Cargo project which must also export a shared library, but maturin takes care of choosing the correct
file depending on the OS, and including it with our distribution automatically.
It supports many bindings alternatives, including cffi using the `tool.maturin.bindings = "cffi"` option.

#figure(
    caption: [Maturin build system setup on pyproject.toml.],
    placement: auto,
    ```toml
    [build-system]
    requires = ["maturin==1.8.6"]
    build-backend = "maturin"
    ```
) <code:maturin-bs>

== PyO3 extension module <sec:pyo3>

As mentioned, PyO3 also builds on maturin and requires a Python project definition specifying the build system such as
in @code:maturin-bs.
To use PyO3 in Rust we need to add it as a dependency with the `extension-module` feature to our Cargo project.
Instead of defining our API directly as `extern "C"` we can use PyO3 helpers to define a Pythonic interface, as
demonstrated in @code:pyo3.

#figure(
    caption: [Rust PyO3 bindings code.],
    placement: auto,
```rs
use statistics as stat;
use pyo3::prelude::*;

#[pyfunction]
fn mean(values: Vec<f64>) -> f64 {
    stat::mean(&values)
}

#[pyfunction]
fn stddev(values: Vec<f64>) -> f64 {
    stat::stddev(&values)
}

#[pymodule]
fn bind_pyo3(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(mean, m)?)?;
    m.add_function(wrap_pyfunction!(stddev, m)?)
}
```
) <code:pyo3>

PyO3 can also wrap Rust structs as native Python classes (shown in @code:pyo3-array), which both makes our interface more adequate for Python users
and allows easy reuse of the converted types, like in our @code:py-ctypes example.

#figure(
    caption: [Rust PyO3 class definition.],
    placement: auto,
```rs
 #[pyclass]
struct Array(Vec<f64>);

#[pymethods]
impl Array {
    #[new]
    fn new(values: Vec<f64>) -> Self {
        Self(values)
    }

    fn mean(&self) -> f64 {
        stat::mean(&self.0)
    }

    fn stddev(&self) -> f64 {
        stat::stddev(&self.0)
    }
}

#[pymodule]
fn bind_pyo3(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_class::<Array>()
}
```
) <code:pyo3-array>

== Summary

As mentioned in @chap:bind, it is customary to use the C ABI for bindings, requiring all implementations to convert to and from it.
We start by considering how the *binary conversion* takes place, which hints on their performance characteristics, then we
discuss *usability* of the generated APIs, and finally *tooling*.
@tab:ffi-impl summarizes implementation details for each FFI alternative.
// For each we implement two alternatives, one where Python data is converted into its C representation for every
// parameter, and another where we only invoke the bindings using pre-converted values, #link("bind:situ")[M1 (in-situ)] and #link("bind:pointer")[M2 (pointer)] respectively.
// The pre-converted variants are associated to optimized usage patterns, generally used in batch processing, while the
// other approach may be more flexible and desirable for native APIs.

#figure(
    caption: [User features of each FFI implementation discussed.],
    placement: auto,
    table(
        align: center + horizon,
        columns: (auto, auto, auto),
        stroke: (top: 0.5pt, bottom: 1pt, left: 0pt, right: 0pt),
        table.header(
            [FFI method],
            [Memory handling],
            [Binding method],
        ),
        [ ctypes ], [ Python ], [ libffi with manual declaration ],
        [ cffi ], [ native ], [ inferred from C API ],
        [ PyO3 ], [ native ], [ inferred from Rust API ],
    )
) <tab:ffi-impl>

=== ctypes

The library exposes C constructor helpers which can be used to specify types.
Those can then be used to specify arguments and return types for the API through custom attributes in a `c.CDLL` instance using libffi, as shown in @code:py-ctypes.

1. Conversion:
    The conversions are performed explicitly by the caller in Python, which hints at bad performance characteristics.
2. Usability
    All type conversions create a separate view of our values, and typing errors often lead to unexpected behavior, making these declarations very error prone.
    The conversions can be abstracted in Python, which is significantly more ergonomic than any other declaration method.
    The one-way nature of the API is taken for granted as a usability concern as a primary limitation of classic FFI methods,
    i.e. those that do not adopt Python extension modules.
3. Tooling
    Using cffi only requires a build-system setup for the shared object file, which might be dispensable depending on the
    use-case (e.g. the library might be installed separately).
    Interfaces can be typed with no additional cost by bindings creators, however the entire process suffers from lack of automation.

=== cffi

Using the C header interface (shown in @code:h) for the API it is possible to auto-generate the Python-C conversions, which are
built into the bindings.
The bound code is available by importing the generated library (requiring build system integration).

1. Conversion:
    Performed implicitly per-call.
    This requires a different export approach in order to enable API api2 using opaque pointers, shown in @code:rsc-array.
2. Usability:
    By creating the bindings as an extension module, the interpreter is able to catch parameter mismatches, and cffi
    itself guarantees the types are converted sensibly.
    While exporting C functions is a more general approach to FFI creation, it severely limits the API expressiveness in Python by default.
    Those bindings can also be supplemented in Python, which is a close approximation to what NumPy offers.
3. Tooling:
    Using Maturin the C headers can be entirely avoided when working with Rust, however the cffi method still requires C exports and all other caveats apply.
    There is no standard tooling for automatic typing declarations, usually requiring the use of `.pyi` files with stubs.

=== PyO3

PyO3 offers Rust macros (code generation) to export functions, enabling Rust-native extension modules while preserving the same working characteristics as cffi with Maturin.
The major difference among them being related to *tooling*, where PyO3 closes the gap in creating more ergonomic
interfaces for users.

// #colbreak()

= Results <chap:bench>

The experimental setup ran on Linux 6.14.19, on a Ryzen 7 5800X CPU.
We used the Rust 1.87.0 toolchain, CPython 3.12.8 standard single-threaded build and Python dependencies NumPy 2.2.0 and cffi 1.17.1.

Experiments were setup by reading the samples from a file, generating the NumPy result to assert implementation
correctness and then timing each using @code:benchmark.
The full benchmark is run 10 times for each sample, using 3 different random samples and measuring total time spent
on the foreign function calls on each of the 30 individual runs.
Benchexec @beyer2019benchexec was used for executing the benchmarks in a container with the `runexec` tool.
The experimental setup is available at #link("https://github.com/isinyaaa/python-ffi")[github.com/isinyaaa/python-ffi].

#figure(
    caption: [Benchmark function using function pointers.
    Prior to the benchmark we stop the Python garbage collector to minimize interpreter overheads.
    The function verifies whether the results is within a 1% tolerance margin from the expected.],
    placement: auto,
```py
import gc
import math
import time

gc.disable()
timer = time.perf_counter_ns


def benchmark(fp, expected, *args, tolerance=0.01):
    start = timer()
    actual = fp(*args)
    end = timer()
    assert not math.isnan(actual) and abs(actual - expected) < tolerance, f"{expected:.3f} != {actual:.3f}"
    return end - start
```
) <code:benchmark>

// Results are shown as mean with standard deviation, and ran on a million values samples as described on @chap:method.

We started by comparing the two API approaches where we either include the binary representation conversion in every
call or not, as described in api1 and api2 respectively.
The results for serial runs along with reference values are shown in serial1
and serial2.
Note that as expected the cffi approach behaves similarly independently of the build system, with differences
accounted for uncertainty.

#show "serial1": [@tab:serial-slow[api1 results table]]
#show "serial2": [@tab:serial-fast[api2 results table]]

#figure(
    caption: [
    Benchmark results for serial runs converting parameters at the call site, as described on api1.
    // The consistent API results simply include type conversion.
],
    placement: auto,
    table(
        align: center + horizon,
        columns: (auto, auto, auto),
        stroke: (top: 0.5pt, bottom: 1pt, left: 0pt, right: 0pt),
        table.header(
            [Method],
            [`mean` (ms)],
            [`stddev` (ms)],
        ),
[ ctypes ], [ 1.978e+05 $plus.minus$ 1.399e+03 ], [ 1.973e+05 $plus.minus$ 1.037e+03 ],
[ cffi (setuptools) ], [ 7.347e+03 $plus.minus$ 216.2 ], [ 7.717e+03 $plus.minus$ 99.04 ],
[ cffi (maturin) ], [ 7.262e+03 $plus.minus$ 60.99 ], [ 7.704e+03 $plus.minus$ 62.76 ],
[ PyO3 ], [ 6.423e+03 $plus.minus$ 34.7 ], [ 6.965e+03 $plus.minus$ 29.37 ],
[ NumPy ], [ 2.561e+04 $plus.minus$ 639.3 ], [ 2.7e+04 $plus.minus$ 627.8 ]
    )
) <tab:serial-slow>

#figure(
    caption: [
    Benchmark results for serial runs using pre-converted types, as described on api2.
    // The consistent API results simply include type conversion.
],
    placement: auto,
    table(
        align: center + horizon,
        columns: (auto, auto, auto),
        stroke: (top: 0.5pt, bottom: 1pt, left: 0pt, right: 0pt),
        table.header(
            [Method],
            [`mean` (ms)],
            [`stddev` (ms)],
        ),
[ ctypes ], [ 1.369e+03 $plus.minus$ 43.84 ], [ 1.658e+03 $plus.minus$ 89.95 ],
[ cffi (setuptools) ], [ 633.1 $plus.minus$ 5.638 ], [ 1.257e+03 $plus.minus$ 8.142 ],
[ cffi (maturin) ], [ 638.2 $plus.minus$ 4.451 ], [ 1.265e+03 $plus.minus$ 5.393 ],
[ PyO3 ], [ 634.7 $plus.minus$ 3.036 ], [ 1.256e+03 $plus.minus$ 6.077 ],
[ NumPy ], [ 262.5 $plus.minus$ 14.35 ], [ 1.594e+03 $plus.minus$ 27.82 ]
    )
) <tab:serial-fast>

As serial1 reveals the expected performance issues with ctypes, being a legacy method we
decided to pursue only the approaches that integrate with Rust and avoid libffi.
The subsequent benchmarks compare only NumPy and PyO3 as the other methods have equivalent implementations and results.

We now present the results for the chunked executions, starting at a chunk size of $2^10$ up to $2^18$ with
intermediate samples in the exponential range, shown in @fig:plot-mean and @fig:plot-std, with values listed on
@tab:chunked-mean and @tab:chunked-std respectively.

#figure(
    caption: [
    Full benchmark results for chunked runs of `mean`, plotted on @fig:plot-mean.
],
    placement: auto,
    table(
        align: center + horizon,
        columns: (auto, auto, auto),
        stroke: (top: 0.5pt, bottom: 1pt, left: 0pt, right: 0pt),
        table.header(
            [Chunk size ($2^n$)],
            [PyO3], [NumPy],
        ),
[ 10.0 ], [ 3.475e+03 $plus.minus$ 53.26 ], [ 759.9 $plus.minus$ 10.56 ],
[ 10.5 ], [ 2.51e+03 $plus.minus$ 27.4 ], [ 722.4 $plus.minus$ 7.956 ],
[ 11.0 ], [ 1.86e+03 $plus.minus$ 29.16 ], [ 696.0 $plus.minus$ 6.109 ],
[ 11.5 ], [ 1.421e+03 $plus.minus$ 14.28 ], [ 677.6 $plus.minus$ 5.118 ],
[ 12.0 ], [ 1.107e+03 $plus.minus$ 13.74 ], [ 661.4 $plus.minus$ 4.354 ],
[ 12.5 ], [ 870.1 $plus.minus$ 12.52 ], [ 651.9 $plus.minus$ 3.613 ],
[ 13.0 ], [ 682.9 $plus.minus$ 4.2 ], [ 644.1 $plus.minus$ 2.497 ],
[ 13.5 ], [ 546.7 $plus.minus$ 7.181 ], [ 640.3 $plus.minus$ 4.441 ],
[ 14.0 ], [ 425.7 $plus.minus$ 5.086 ], [ 635.2 $plus.minus$ 4.231 ],
[ 14.5 ], [ 343.8 $plus.minus$ 3.869 ], [ 632.6 $plus.minus$ 2.779 ],
[ 15.0 ], [ 286.1 $plus.minus$ 5.175 ], [ 630.0 $plus.minus$ 3.308 ],
[ 15.5 ], [ 244.0 $plus.minus$ 3.43 ], [ 629.2 $plus.minus$ 3.21 ],
[ 16.0 ], [ 212.9 $plus.minus$ 2.755 ], [ 628.3 $plus.minus$ 2.759 ],
[ 16.5 ], [ 190.4 $plus.minus$ 2.169 ], [ 626.8 $plus.minus$ 3.805 ],
[ 17.0 ], [ 173.8 $plus.minus$ 2.389 ], [ 627.2 $plus.minus$ 3.346 ],
[ 17.5 ], [ 165.5 $plus.minus$ 1.502 ], [ 626.2 $plus.minus$ 3.15 ],
[ 18.0 ], [ 154.9 $plus.minus$ 1.963 ], [ 626.1 $plus.minus$ 1.835 ],
[ 18.5 ], [ 153.2 $plus.minus$ 2.77 ], [ 625.3 $plus.minus$ 2.01 ]
)) <tab:chunked-mean>

#figure(
    caption: [
    Chunked execution results for `mean()`.
    The sample size is divided in chunks and the execution times are summed for each implementation.
    The maximum error occurs at the least sample size of $2^10$ with 10.5 ms for PyO3 and 53.3 ms for NumPy (shown in
    @tab:chunked-mean).
],
    placement: auto,
    image("plots/mean.png", width: 100%),
) <fig:plot-mean>


#figure(
    caption: [
    Full benchmark results for chunked runs of `std`, plotted on @fig:plot-std.
],
    placement: auto,
    table(
        align: center + horizon,
        columns: (auto, auto, auto),
        stroke: (top: 0.5pt, bottom: 1pt, left: 0pt, right: 0pt),
        table.header(
            [Chunk size ($2^n$)],
            [PyO3], [NumPy],
        ),
[ 10.0 ], [ 1.348e+03 $plus.minus$ 11.59 ], [ 9.382e+03 $plus.minus$ 64.0 ],
[ 10.5 ], [ 1.316e+03 $plus.minus$ 5.457 ], [ 6.808e+03 $plus.minus$ 61.71 ],
[ 11.0 ], [ 1.296e+03 $plus.minus$ 5.033 ], [ 5.04e+03 $plus.minus$ 46.21 ],
[ 11.5 ], [ 1.285e+03 $plus.minus$ 8.125 ], [ 3.825e+03 $plus.minus$ 53.61 ],
[ 12.0 ], [ 1.278e+03 $plus.minus$ 3.923 ], [ 2.928e+03 $plus.minus$ 22.35 ],
[ 12.5 ], [ 1.272e+03 $plus.minus$ 5.9 ], [ 2.258e+03 $plus.minus$ 12.12 ],
[ 13.0 ], [ 1.264e+03 $plus.minus$ 8.286 ], [ 1.791e+03 $plus.minus$ 14.13 ],
[ 13.5 ], [ 1.258e+03 $plus.minus$ 4.963 ], [ 1.466e+03 $plus.minus$ 8.84 ],
[ 14.0 ], [ 1.253e+03 $plus.minus$ 3.192 ], [ 1.233e+03 $plus.minus$ 6.972 ],
[ 14.5 ], [ 1.253e+03 $plus.minus$ 3.767 ], [ 1.071e+03 $plus.minus$ 9.129 ],
[ 15.0 ], [ 1.251e+03 $plus.minus$ 2.522 ], [ 958.8 $plus.minus$ 9.865 ],
[ 15.5 ], [ 1.251e+03 $plus.minus$ 3.793 ], [ 880.5 $plus.minus$ 9.754 ],
[ 16.0 ], [ 1.25e+03 $plus.minus$ 2.485 ], [ 828.2 $plus.minus$ 6.539 ],
[ 16.5 ], [ 1.249e+03 $plus.minus$ 3.641 ], [ 787.8 $plus.minus$ 3.932 ],
[ 17.0 ], [ 1.249e+03 $plus.minus$ 3.29 ], [ 765.5 $plus.minus$ 6.135 ],
[ 17.5 ], [ 1.246e+03 $plus.minus$ 2.854 ], [ 757.9 $plus.minus$ 4.599 ],
[ 18.0 ], [ 1.248e+03 $plus.minus$ 2.348 ], [ 772.5 $plus.minus$ 6.2 ],
[ 18.5 ], [ 1.249e+03 $plus.minus$ 2.177 ], [ 819.2 $plus.minus$ 7.03 ]
)) <tab:chunked-std>

#figure(
    caption: [
    Chunked execution results for `std()`.
    The sample size is divided in chunks and the execution times are summed for each implementation.
    The maximum error occurs at the least sample size of $2^10$ with 11.6 ms for PyO3 and 64.0 ms for NumPy (shown in
    @tab:chunked-std).
],
    placement: auto,
    image("plots/std.png", width: 100%),
) <fig:plot-std>

To measure the relative overhead against the NumPy calculations, we subtract the minimum timing from the chunked
results (shown as the dashed line on @fig:plot-mean and @fig:plot-std) and take them as a function of the number of calls
-- the sample size divided by the chunk size ($10^9/2^n$) -- shown in @fig:plot-freq-mean and @fig:plot-freq-std.

#figure(
    caption: [
    Function call overhead for `mean()`.
    The least execution time for Numpy is subtracted from @fig:plot-mean.
    Frequency measures the amount of function calls.
],
    placement: auto,
    image("plots/add_mean.png", width: 100%),
) <fig:plot-freq-mean>

#figure(
    caption: [
    Function call overhead for `std()`.
    The least execution time for Numpy is subtracted from @fig:plot-std.
    Frequency measures the amount of function calls.
],
    placement: auto,
    image("plots/add_std.png", width: 100%),
) <fig:plot-freq-std>

Finally, we present the linear regression results for the function call overheads measured against the best case for
NumPy (@fig:plot-freq-mean and @fig:plot-freq-std) in @tab:linreg-results.

#figure(
    caption: [
    Linear regression for function call overheads. per-call overhead corresponds to the angular coefficient while base
    shows the constant overhead against the best NumPy execution.
],
    placement: auto,
    table(
        align: center + horizon,
        columns: (auto, auto, auto, auto, auto),
        stroke: (top: 0.5pt, bottom: 1pt, left: 0pt, right: 0pt),
        table.header(
            table.cell(rowspan: 2,
            [Method]),
            table.cell(colspan: 2,
                [`mean` (ms)]),
            table.cell(colspan: 2,
                [`stddev` (ms)]),
            [per-call], [base],
            [per-call], [base],
        ),
[ PyO3 ], [ 0.1408 $plus.minus$ 0.001476 ], [472.7 $plus.minus$ 0.3195],
[ 0.1017 $plus.minus$ 0.002395 ], [1.095e+03 $plus.minus$ 0.5547],
[ NumPy ], [ 3.562 $plus.minus$ 0.08204 ], [14.36 $plus.minus$ 9.941],
[ 8.878 $plus.minus$ 0.06025 ], [560.9 $plus.minus$ 8.442],
    )
) <tab:linreg-results>

// #colbreak()

= Analysis <chap:analysis>

Going back to @chap:design, it is clear that ctypes is the most lacking alternative, requiring manual API redefinitions
and expensive type constructions due to libffi clearly outweighing any benefits as can be seen on
serial1.
cffi can allow for easy performance gains and can also be integrated with Rust, making for a solid alternative for any
libraries that already have shared library builds.
PyO3 provides the most flexibility when creating the Python bindings, which may be an advantage for library
implementers as they need workable APIs.
The build systems are considered part of the tooling, and irrelevant for the benchmark.

In @fig:plot-std the NumPy implementation hits a minimum at a chunk size of $2^16$, which corresponds to 512KB
of memory for 64 bit values, and also the machine L2 cache size#footnote[
    Queried with `lscpu -C`.
], which indicates that their implementation makes full use of the machine resources.
It is curious that after rebounding from that minimum, at the full sample size, our implementation outperforms
NumPy by a small margin (seen on serial2) with no explicit SIMD
instructions#footnote[
    It is possible to instruct the Rust compiler to use specific optimizations, or inline assembly.
], which NumPY makes heavy use of.

// In @fig:plot-mean as the chunk size increases we are performing less function calls, which reveals a smaller
// overhead in our methods compared to the NumPy library, confirming the gap between @tab:serial-slow-results and @tab:serial-fast-results.
Due to the difficulty of specifying flexible interfaces in standard C extension modules, NumPy defines its interfaces
in pure Python, wrapping the appropriate low-level functions depending on e.g. value types or the data shape.
In both @fig:plot-freq-mean and @fig:plot-freq-std we can confirm the massive interpreter overhead caused by those
interfaces, which contrasts heavily with the higher base overhead but lower per-call overhead in our custom
implementations, as can be seen on @tab:linreg-results.

@tab:ffi-code summarizes the analysis results regarding each of the objectives laid out on @sec:quest.

#figure(
caption: [
    Bindings methods analysis summary.
    Note that all cffi accidental complexity can also be found on ctypes.
    We note each detail that requires usage of `unsafe` in Rust separately.
],
    placement: auto,
table(
    align: center + horizon,
    columns: (auto, auto, auto, auto),
    stroke: (top: 0.5pt, bottom: 1pt, left: 0pt, right: 0pt),
    table.header(
        [Method], [Accidental Complexity], [Gaps in tooling], [Performance relative to NumPy]
    ),
    [ctypes],[
        Manual API (re-)declaration \
        Manual type (re-)construction \
        Requires libffi (dynamic symbol resolution) \
        Inherits issues present on ctypes
    ],[
        Build system integration
    ],[Poor],
    [cffi],[
        Opaque `struct` exports \
        Manual memory casts (unsafe)
    ],[
        Unclear documentation
    ],[Comparable],
    [PyO3],[
        -
    ],[
        -
    ],[Comparable],
)
) <tab:ffi-code>

// #colbreak()

= Conclusion <chap:final>

This study investigated the effectiveness of modern tooling for developing state-of-the-art libraries for Python, a
high-level language known for its slow interpreter, which required arcane tooling to be bypassed.
We evaluated the Rust-based PyO3 toolchain with three questions in mind: finding its accidental complexity requirements
obj1; understanding limitations in tooling obj2;
and its relative performance against state-of-the-art implementations obj3.

== Research question 1 #link(<obj:accident>)[(conciseness)]

This question was investigated through the actual implementations on @chap:design.
Comparing those it is clear that PyO3's only issue in conciseness could come from the Rust language itself, which can
be compared to C++ in some aspects.
The library hides many of the lower-level details from the required C exports, while also preserving performance, which
effectively makes it close a tooling gap for using Rust for this purpose.

== Research question 2 #link(<obj:tool>)[(gaps in tooling)]

This question was investigated through the actual implementations on @chap:design.
While this may be quite subjective, there are universal issues with both ctypes and cffi related to the legacy nature
of the tools, i.e. because there is no standard tooling for C itself.
However, we found both to be quite workable when the setup was correct, with most issues arising on the first-time
setup.
Gaps in tooling often appear under more specific circumstances, often in real-world scenarios, and while we provide
generalizable APIs the lack in variety of use-cases might be seen as a weakness of this study.

== Research question 3 #link(<obj:speed>)[(speed)]

This question was investigated through the performance analysis @chap:analysis.
The experiments show that it is possible to outperform existing state-of-the-art libraries for specific use-cases,
and ideally exposing the bindings without additional layers of abstraction, with the main takeaway that this can be
done without Rust-specific speed-up techniques.

== Insights

This study has shown that PyO3 offers ergonomic advantages in relation to C-specific tooling such as cffi, with vast
possibilities for optimizations.
By offering higher-level tooling to bindings implementers it allows for Python-native interfaces with minimal per-call
overhead.
To optimize bindings implementers should always focus on separating large type conversions and delineating memory
boundaries.

== Limitations

This study purposefully limited its scope to comparing only easily implementable mathematical functions in order to
focus on the main aspects regarding FFI performance, in favor of a complete optimization of specific algorithms.
The most pressing limitation in this regard is that it does not illustrate many considerations in switching from C to
Rust, or the actual implementation of lower-level optimizations.

== Future work

Future work might investigate other data structure conversions comparing memory layout differences.
It could also be useful to instrument the Python interpreter and understand the actual overheads in detail.

#bibliography("refs.bib", style: "ieee", title: "References")

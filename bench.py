import gc
import math
import time
import typing as t
from collections import defaultdict
from dataclasses import dataclass

gc.disable()
timer = time.perf_counter_ns


def measure(fp, expected, *args, tolerance=0.01):
    start = timer()
    actual = fp(*args)
    end = timer()
    assert not math.isnan(actual) and abs(actual - expected) < tolerance, (
        f"{expected:.3f} != {actual:.3f}"
    )
    return end - start


import numpy as np
from bind_maturin_cffi import lib as maturin

import bind_ctypes as ctypes
import bind_pyo3 as pyo
from bind_cffi import lib as cffi


@dataclass
class BenchImpl:
    builder: t.Callable[[t.Sequence[float]], tuple[t.Any, ...]]
    mean: t.Callable
    stddev: t.Callable
    is_cls: bool = False

    @classmethod
    def for_cls(cls, builder) -> t.Self:
        return cls(builder, lambda: (), lambda: (), is_cls=True)

    def __call__(self, data: t.Sequence[float]) -> tuple[int, int]:
        nda = np.array(data)
        mean = np.mean(nda)
        std = np.std(nda)
        if self.is_cls:
            cls = self.builder(data)
            m = measure(cls.mean, mean)
            s = measure(cls.stddev, std)
        else:
            bargs = self.builder(data)
            m = measure(self.mean, mean, *bargs)
            s = measure(self.stddev, std, *bargs)
        return m, s


def ctypes_mean(ls: list[float]) -> float:
    return ctypes.lib.mean(*ctypes.array(ctypes.as_f64(ls), len(ls)))


def ctypes_stddev(ls: list[float]) -> float:
    return ctypes.lib.stddev(*ctypes.array(ctypes.as_f64(ls), len(ls)))


class NPWrap:
    def __init__(self, v) -> None:
        self.data = np.array(v, dtype=np.float64)

    def mean(self):
        return self.data.mean()

    def stddev(self):
        return self.data.std()


ref = {
    "nparray": BenchImpl(lambda d: (np.array(d),), np.mean, np.std),
    "numpy": BenchImpl(lambda d: (d,), np.mean, np.std),
}

ctypes_impls = {
    "slow": BenchImpl(lambda d: (d,), ctypes_mean, ctypes_stddev),
    "fast": BenchImpl(
        lambda d: ctypes.array(ctypes.as_f64(d), len(d)),
        ctypes.lib.mean,
        ctypes.lib.stddev,
    ),
}

slow_impls = {
    "setuptools": BenchImpl(lambda d: (d, len(d)), cffi.mean, cffi.stddev),
    "maturin": BenchImpl(lambda d: (d, len(d)), maturin.mean, maturin.stddev),
    "pyo3": BenchImpl(lambda d: (d,), pyo.mean, pyo.stddev),
}

fast_impls = {
    "setuptools": BenchImpl(
        lambda d: (cffi.array_init(d, len(d)),), cffi.array_mean, cffi.array_stddev
    ),
    "maturin": BenchImpl(
        lambda d: (maturin.array_init(d, len(d)),),
        maturin.array_mean,
        maturin.array_stddev,
    ),
    "pyo3": BenchImpl.for_cls(pyo.Array),
}

fastest_impls = {
    # "maturin": BenchImpl(
    #     lambda d: (maturin.array_init(d, len(d)),),
    #     maturin.array_mean,
    #     maturin.array_stddev,
    # ),
    "pyo3": BenchImpl.for_cls(pyo.Array),
    "numpy": BenchImpl(lambda d: (np.array(d),), np.mean, np.std),
}


def get_stat(nst):
    mst = np.array(nst, dtype=np.float64) / 1000
    return np.mean(mst), np.std(mst)


EXPERIMENTS = 5

if __name__ == "__main__":
    import json
    from pathlib import Path
    from sys import argv

    counter = argv[1]

    data = [float(a) for a in Path("values.txt").read_text().splitlines()]
    length = len(data)

    mean_results = defaultdict(dict)
    std_results = defaultdict(dict)

    def irun(chunks, impls, label):
        print("executing", label)
        mean_results.clear()
        std_results.clear()

        for chunk_size in chunks:
            print("chunk size", chunk_size)
            batch = defaultdict(list)
            for _ in range(EXPERIMENTS):
                for name, impl in impls.items():
                    mean_acc, std_acc = 0, 0
                    last = 0
                    for c in range(chunk_size, length, chunk_size):
                        m, s = impl(data[last:c])
                        mean_acc += m
                        std_acc += s
                        last = c
                    if last != length:
                        m, s = impl(data[last:])
                        mean_acc += m
                        std_acc += s
                    batch[name].append((mean_acc, std_acc))

            for name, rs in batch.items():
                print("\t", name)
                mt, st = zip(*rs)
                mean_results[name][str(chunk_size)] = mt
                std_results[name][str(chunk_size)] = st
                # mt, st = add_entry(rs, str(chunk_size))
                mt_mean, mt_std = get_stat(mt)
                st_mean, st_std = get_stat(st)
                print(f"\t\tmean: {mt_mean:.2f}ms +- {mt_std:.2f}ms")
                print(f"\t\tstd: {st_mean:.2f}ms +- {st_std:.2f}ms")

        res_path = Path.cwd() / "results"
        res_path.mkdir(exist_ok=True)
        (res_path / f"{counter}_{label}_mean_{length}.json").write_text(
            json.dumps(mean_results)
        )
        (res_path / f"{counter}_{label}_std_{length}.json").write_text(
            json.dumps(std_results)
        )

    # serial runs
    irun((length,), ctypes_impls, "ctypes")
    irun((length,), slow_impls, "serial_slow")
    irun((length,), fast_impls, "serial_fast")
    irun((length,), ref, "serial_reference")

    # aligned runs
    irun(
        (int(2 ** (e / 2 + 10)) for e in range(2 * (int(math.log2(length)) - 10))),
        fastest_impls,
        "mixed",
    )

    # unaligned runs
    # irun(range(2**11 - 5, 2**12 + 5), fast_impls, "unaligned_fast")
    # irun(range(2**11 - 1024, 2**18 + 1025, 1024), fastest_impls, "unaligned")

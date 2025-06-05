# /// script
# dependencies = ["numpy"]
# ///
from datetime import datetime

import numpy as np

N = 100_000_000


def gen_rand():
    return np.random.randint(0, 92_233_720_368, N)
    # return [random.randint(0, 92_233_720_368) for _ in range(N)]


if __name__ == "__main__":
    rand = gen_rand()
    # ns = np.array(ns)
    start = datetime.now()
    s = rand.sum()
    end = datetime.now()
    tt = (end - start).total_seconds() * 1000
    print("numpy", s, tt, "ms")

    ns = rand.tolist()
    start = datetime.now()
    s = sum(ns)
    end = datetime.now()
    tt = (end - start).total_seconds() * 1000
    print("stdlib", s, tt, "ms")

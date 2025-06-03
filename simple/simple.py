# /// script
# dependencies = ["numpy"]
# ///
import random
from datetime import datetime

import numpy as np

N = 100_000_000


if __name__ == "__main__":
    ns = [random.randint(0, 92_233_720_368) for _ in range(N)]
    start = datetime.now()
    s = sum(ns)
    end = datetime.now()
    tt = (end - start).total_seconds() * 1000
    print("stdlib", s, tt, "ms")

    ns = np.array(ns)
    start = datetime.now()
    s = ns.sum()
    end = datetime.now()
    tt = (end - start).total_seconds() * 1000
    print("numpy", s, tt, "ms")

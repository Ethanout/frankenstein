"""Offline float-model benchmark for the datapack pow design.

This intentionally models the same range reduction and Horner polynomials as
the generated functions. It is not a substitute for an in-game MSPT run.
"""
from __future__ import annotations

import json
import math
import random
import time


def log2_approx(x: float, segments: int, degree: int) -> float:
    k = math.floor(math.log2(x))
    z = x / (2.0**k)
    i = min(segments - 1, int((z - 1.0) * segments))
    c = 1.0 + (i + 0.5) / segments
    u = (z - c) / c
    p = 0.0
    for n in range(degree, 0, -1):
        if n == 1:
            coeff = 1.0 / math.log(2.0)
        elif n == 2:
            coeff = -0.5 / math.log(2.0)
        elif n == 3:
            coeff = 1.0 / (3.0 * math.log(2.0))
        else:
            coeff = -0.25 / math.log(2.0)
        p = (p + coeff) * u
    return k + math.log2(c) + p


def exp2_approx(t: float, segments: int, degree: int) -> float:
    n = math.floor(t + 0.5)
    r = t - n
    i = min(segments - 1, int((r + 0.5) * segments))
    c = -0.5 + (i + 0.5) / segments
    v = r - c
    p = 0.0
    for order in range(degree, 0, -1):
        coeff = math.log(2.0) ** order / math.factorial(order)
        p = (p + coeff) * v
    return (2.0**n) * (2.0**c) * (1.0 + p)


def generic_pow(x: float, y: float, segments: int, degree: int) -> float:
    return exp2_approx(y * log2_approx(x, segments, degree), segments, degree)


def main() -> None:
    random.seed(0xF1A)
    samples = [2.0 ** (random.uniform(-30.0, 30.0)) for _ in range(20000)]
    samples += [1.0 + i / 10000.0 for i in range(1, 10000)]
    rows = []
    for segments in (16, 32, 64):
        for degree in (2, 3, 4):
            worst_abs = 0.0
            worst_rel = 0.0
            started = time.perf_counter()
            count = 0
            for x in samples:
                y = random.uniform(-8.0, 8.0)
                expected = math.pow(x, y)
                actual = generic_pow(x, y, segments, degree)
                worst_abs = max(worst_abs, abs(actual - expected))
                if expected:
                    worst_rel = max(worst_rel, abs((actual - expected) / expected))
                count += 1
            elapsed = time.perf_counter() - started
            rows.append({
                "segments": segments,
                "degree": degree,
                "samples": count,
                "max_absolute_error": worst_abs,
                "max_relative_error": worst_rel,
                "reference_seconds": elapsed,
            })
    rows.sort(key=lambda row: (row["max_relative_error"], row["reference_seconds"]))
    print(json.dumps({"model": "float", "range": "2^-30..2^30", "results": rows}, indent=2))


if __name__ == "__main__":
    main()

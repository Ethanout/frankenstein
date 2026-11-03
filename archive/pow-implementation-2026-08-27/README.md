# Frankenstein

A Minecraft Java `26.3-snapshot-10` data pack project built with Beet, Bolt,
Bolt Expressions, and Mecha. It implements `x^y` without a native `pow`
provider, using Snapshot `compute`, number providers, storage, scoreboards,
and generated functions.

## Commands

```powershell
beet build
beet watch
```

Put data pack files under `src/data/frankenstein`. The load entry point is `frankenstein:load`.

## API

Write `io.x` and `io.y` in storage `frankenstein:pow`, then call
`frankenstein:pow/storage`; the result is written to `io.result` and status to
`tmp.status` (`0` success, `1` undefined real result, `2` overflow,
`3` underflow). `frankenstein:pow/score` is the scoreboard adapter.

The production approximation uses 32 segments and a third-order Horner
polynomial. Integer exponents use bounded binary exponentiation. Reduced
fractions with denominators 2, 4, 8, and 16 use repeated Newton square roots.
The generic path is intended for positive bases in `2^-30..2^30`; values beyond
that command-safe range require a wider scaling tree before production use.

`tools/benchmark_pow.py` compares table sizes and polynomial degrees against
Python's `pow`. MSPT must be measured in the target Snapshot server; this
repository does not claim C `pow(double)` precision or provide a benchmark
result without that server run.

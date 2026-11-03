# Pow benchmark

Run `python tools/benchmark_pow.py` to compare 16/32/64 log2 and exp2 table
segments with second-, third-, and fourth-order Horner polynomials. The model
uses Python `float` as a reference for the Snapshot's Java `float` provider;
the result is an offline approximation error comparison, not an MSPT result.

In-game performance should be measured with `/perf start`, `/perf stop`, and
the generated `frankenstein:benchmark/storage` function. `#units` counts the
datapack's explicit benchmark invocations; it is not a server-internal score
addition counter.

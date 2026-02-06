
# Benchmark

## wc

### wc -l

Benchmark based on a not so naive implementation on 2026-02-06. Short line files are a problem, but with real life file this not full optimized implementation is faster than GNU and FreeBSD / macOS.

**System:** Darwin 25.2.0 arm64

**Swift:** Apple Swift version 6.2 (swift-6.2-RELEASE)
Target: arm64-apple-macosx26.0
Build config: +assertions
| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `/usr/bin/wc -l moby64.txt` | 78.5 ± 1.6 | 76.5 | 80.3 | 9.72 ± 0.93 |
| `/opt/homebrew/bin/gwc -l moby64.txt` | 24.3 ± 0.4 | 23.7 | 25.1 | 3.01 ± 0.28 |
| `./uutils/target/release/wc -l moby64.txt` | 8.1 ± 0.8 | 7.1 | 9.6 | 1.00 |
| `../../../.build/release/wc -l moby64.txt` | 14.5 ± 0.8 | 13.7 | 16.2 | **1.79** ± 0.19 |
|---|---|---|---|---|
| `/usr/bin/wc -l odyssey256.txt` | 72.0 ± 0.2 | 71.8 | 72.6 | 9.23 ± 0.33 |
| `/opt/homebrew/bin/gwc -l odyssey256.txt` | 22.3 ± 0.3 | 21.8 | 22.7 | 2.86 ± 0.11 |
| `./uutils/target/release/wc -l odyssey256.txt` | 7.8 ± 0.3 | 7.4 | 8.3 | 1.00 |
| `../../../.build/release/wc -l odyssey256.txt` | 13.2 ± 0.6 | 12.5 | 14.7 | **1.70** ± 0.10 |
|---|---|---|---|---|
| `/usr/bin/wc -l 25Mshortlines.txt` | 48.7 ± 0.3 | 48.4 | 49.1 | 8.44 ± 0.44 |
| `/opt/homebrew/bin/gwc -l 25Mshortlines.txt` | 20.2 ± 0.3 | 19.6 | 20.6 | 3.51 ± 0.19 |
| `./uutils/target/release/wc -l 25Mshortlines.txt` | 5.8 ± 0.3 | 5.2 | 6.4 | 1.00 |
| `../../../.build/release/wc -l 25Mshortlines.txt` | 129.8 ± 0.7 | 128.8 | 131.4 | **22.50** ± 1.18 |

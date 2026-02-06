
# Benchmark

## wc

### wc -l

Benchmark based on **naive implementation on 2026-02-05**. Rust implementation is more than 700 times faster; this was expected.

**System:** Darwin 25.2.0 arm64

**Swift:** Apple Swift version 6.2 (swift-6.2-RELEASE)
Target: arm64-apple-macosx26.0
Build config: +assertions

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `/usr/bin/wc -l moby64.txt` | 80.4 ± 1.3 | 78.2 | 81.3 | 10.29 ± 0.51 |
| `/opt/homebrew/bin/gwc -l moby64.txt` | 25.4 ± 0.3 | 25.0 | 25.7 | 3.25 ± 0.16 |
| `./uutils/target/release/wc -l moby64.txt` | 7.8 ± 0.4 | 7.4 | 8.3 | 1.00 |
| `../../../.build/release/wc -l moby64.txt` | 6684.5 ± 47.4 | 6640.7 | 6749.8 | **855.51** ± 40.81 |
|---|---|---|---|---|
| `/usr/bin/wc -l odyssey256.txt` | 71.7 ± 1.0 | 70.9 | 73.3 | 9.79 ± 0.32 |
| `/opt/homebrew/bin/gwc -l odyssey256.txt` | 20.9 ± 0.3 | 20.7 | 21.3 | 2.86 ± 0.09 |
| `./uutils/target/release/wc -l odyssey256.txt` | 7.3 ± 0.2 | 7.2 | 7.7 | 1.00 |
| `../../../.build/release/wc -l odyssey256.txt` | 6115.3 ± 37.4 | 6069.6 | 6169.4 | **834.99** ± 25.52 |
|---|---|---|---|---|
| `/usr/bin/wc -l 25Mshortlines.txt` | 48.3 ± 0.8 | 47.6 | 49.3 | 8.71 ± 0.50 |
| `/opt/homebrew/bin/gwc -l 25Mshortlines.txt` | 20.1 ± 0.4 | 19.8 | 20.6 | 3.63 ± 0.21 |
| `./uutils/target/release/wc -l 25Mshortlines.txt` | 5.5 ± 0.3 | 5.2 | 6.0 | 1.00 |
| `../../../.build/release/wc -l 25Mshortlines.txt` | 4246.7 ± 22.1 | 4225.6 | 4282.3 | **765.95** ± 42.03 |

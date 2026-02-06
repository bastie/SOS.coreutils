
# Benchmark

## wc

### wc -l

Benchmark based on another naive implementation on 2026-02-06. Rust implementation is upto 250 times faster; this was expected. Now `wc -l` doesnt do thinks - like String creating.

**System:** Darwin 25.2.0 arm64

**Swift:** Apple Swift version 6.2 (swift-6.2-RELEASE)
Target: arm64-apple-macosx26.0
Build config: +assertions

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `/usr/bin/wc -l moby64.txt` | 80.6 ± 0.2 | 80.5 | 80.9 | 7.92 ± 1.14 |
| `/opt/homebrew/bin/gwc -l moby64.txt` | 25.8 ± 1.0 | 25.0 | 27.4 | 2.54 ± 0.38 |
| `./uutils/target/release/wc -l moby64.txt` | 10.2 ± 1.5 | 8.3 | 11.6 | 1.00 |
| `../../../.build/release/wc -l moby64.txt` | 1055.9 ± 5.5 | 1051.3 | 1065.3 | **103.77** ± 14.97 |
|---|---|---|---|---|
| `/usr/bin/wc -l odyssey256.txt` | 72.1 ± 0.1 | 71.9 | 72.2 | 8.62 ± 0.40 |
| `/opt/homebrew/bin/gwc -l odyssey256.txt` | 21.3 ± 0.4 | 20.7 | 21.7 | 2.55 ± 0.12 |
| `./uutils/target/release/wc -l odyssey256.txt` | 8.4 ± 0.4 | 8.0 | 8.8 | 1.00 |
| `../../../.build/release/wc -l odyssey256.txt` | 777.0 ± 2.0 | 775.0 | 779.9 | **92.99** ± 4.28 |
| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|---|---|---|---|---|
| `/usr/bin/wc -l 25Mshortlines.txt` | 51.1 ± 0.1 | 51.0 | 51.3 | 8.85 ± 0.49 |
| `/opt/homebrew/bin/gwc -l 25Mshortlines.txt` | 20.4 ± 0.7 | 19.5 | 21.2 | 3.53 ± 0.23 |
| `./uutils/target/release/wc -l 25Mshortlines.txt` | 5.8 ± 0.3 | 5.4 | 6.3 | 1.00 |
| `../../../.build/release/wc -l 25Mshortlines.txt` | 1346.5 ± 8.8 | 1338.9 | 1359.6 | **233.25** ± 12.95 |

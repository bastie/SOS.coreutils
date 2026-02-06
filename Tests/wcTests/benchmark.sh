#!/bin/zsh
# SPDX-License-Identifier: 0BSD OR Apache-2.0 OR EUPL-1.2
# SPDX-FileCopyrightText: © 2026 Sebastian Ritter

# run benchmark on macOS CLI
# Version 0.1
# - naive, only run not check, it works with installed Rust and Homebrew on macOS

export TIMESTAMP="$(date +'%Y-%m-%d_%H-%M')"

# build own release

cd ../..
swift build -c release
cd Tests/wcTests

# get GNU coreutils
# brew upgrade
brew install coreutils git

mkdir benchmark
cd benchmark

# build Rust uutils
git clone https://github.com/uutils/coreutils.git uutils
cd uutils
git fetch
git pull
cargo build --release -p uu_wc
cd ..


## now we have
# FreeBSD aka macOS variant: /usr/bin/wc
# GNU coreutils:             /opt/homebrew/bin/gwc
# Rust uutils:               ./uutils/target/release/wc
# SOSutils:                  ../../../.build/release/wc

# like uutils, create test data
yes | head -c50000000 > 25Mshortlines.txt

curl https://www.gutenberg.org/files/2701/2701-0.txt -o moby.txt
cat moby.txt moby.txt moby.txt moby.txt > moby4.txt
cat moby4.txt moby4.txt moby4.txt moby4.txt > moby16.txt
cat moby16.txt moby16.txt moby16.txt moby16.txt > moby64.txt

curl https://www.gutenberg.org/files/30613/30613-0.txt -o odyssey.txt
cat odyssey.txt odyssey.txt odyssey.txt odyssey.txt > odyssey4.txt
cat odyssey4.txt odyssey4.txt odyssey4.txt odyssey4.txt > odyssey16.txt
cat odyssey16.txt odyssey16.txt odyssey16.txt odyssey16.txt > odyssey64.txt
cat odyssey64.txt odyssey64.txt odyssey64.txt odyssey64.txt > odyssey256.txt

echo "--- run benchmark now ---"
echo ${TIMESTAMP}

hyperfine --warmup 3 --runs 5 "/usr/bin/wc -l moby64.txt" "/opt/homebrew/bin/gwc -l moby64.txt" "./uutils/target/release/wc -l moby64.txt" "../../../.build/release/wc -l moby64.txt" --export-markdown result_moby64_${TIMESTAMP}.md
hyperfine --warmup 3 --runs 5 "/usr/bin/wc -l odyssey256.txt" "/opt/homebrew/bin/gwc -l odyssey256.txt" "./uutils/target/release/wc -l odyssey256.txt" "../../../.build/release/wc -l odyssey256.txt" --export-markdown result_odyssey256_${TIMESTAMP}.md
hyperfine --warmup 3 --runs 5 "/usr/bin/wc -l 25Mshortlines.txt" "/opt/homebrew/bin/gwc -l 25Mshortlines.txt" "./uutils/target/release/wc -l 25Mshortlines.txt" "../../../.build/release/wc -l 25Mshortlines.txt" --export-markdown result_25Mshortlines_${TIMESTAMP}.md

echo "### wc -l" >results_${TIMESTAMP}.md
uname -mor >results_${TIMESTAMP}.md
echo " " >>results_${TIMESTAMP}.md
swift --version >>results_${TIMESTAMP}.md
cat result_moby64_${TIMESTAMP}.md result_odyssey256_${TIMESTAMP}.md result_25Mshortlines_${TIMESTAMP}.md >>results_${TIMESTAMP}.md

rm result_*.md

cd ..
# rm -rf benchmark


echo "--- EOF ---"

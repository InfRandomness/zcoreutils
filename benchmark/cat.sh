#!/bin/bash

# Setting up steps
printf "Setting up the testing environment...\n"
printf "Creating a tiny file with repetitive lines of text\n"
yes "Some text" | head -n 1000 > tiny-file
printf "Creating a tiny file with repetitive lines of text\n"
yes "Some text" | head -n 10000 > regular-file
printf "Create big file with repetitive lines of text\n"
yes "Some text" | head -n 100000 > big-file

# Benchmarking steps
printf "Benchmarking zcoreutils's cat command...\n"
hyperfine --warmup 5 --min-runs 10 '../zig-cache/bin/cat tiny-file' '../zig-cache/bin/cat regular-file' '../zig-cache/bin/cat big-file'
printf "Benchmarking coreutils' cat command\n"
hyperfine --warmup 5 --min-runs 10 'cat tiny-file' 'cat regular-file' 'cat big-file'

# Cleanup steps
printf "Cleaning up...\n"
rm ./*-file
#!/bin/bash

generate_text () {
    yes "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." \
    | dd iflag=fullblock of="$1" bs="$2" count="$3"
}

# Setting up steps
printf "Setting up the testing environment...\n"
printf "Creating a tiny file with repetitive lines of text\n"
generate_text "tiny-file" "100k" "6"
printf "Creating a tiny file with repetitive lines of text\n"
generate_text "regular-file" "10M" "10"
printf "Create big file with repetitive lines of text\n"
generate_text "big-file" "100M" "10"

# Benchmarking steps
printf "Benchmarking zcoreutils's cat command...\n"
hyperfine --warmup 5 --min-runs 10 '../zig-out/bin/cat tiny-file' '../zig-out/bin/cat regular-file' '../zig-out/bin/cat big-file'
printf "Benchmarking coreutils' cat command\n"
hyperfine --warmup 5 --min-runs 10 'cat tiny-file' 'cat regular-file' 'cat big-file'

# Cleanup steps
printf "Cleaning up...\n"
rm ./*-file
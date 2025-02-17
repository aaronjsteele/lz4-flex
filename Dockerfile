# Use Rust to build
FROM rustlang/rust:nightly as builder

# Add source code to the build stage.
ADD . /lz4_flex
WORKDIR /lz4_flex

RUN cargo install cargo-fuzz

# BUILD INSTRUCTIONS
WORKDIR /lz4_flex/fuzz
RUN cargo +nightly fuzz build fuzz_decomp_corrupt_block
# Output binaries are placed in /lz4-flex/fuzz/target/x86_64-unknown-linux-gnu/release

# Package Stage -- we package for a plain Ubuntu machine
FROM --platform=linux/amd64 ubuntu:20.04

## Copy the binary from the build stage to an Ubuntu docker image
COPY --from=builder /lz4_flex/fuzz/target/x86_64-unknown-linux-gnu/release/fuzz_decomp_corrupt_block /fuzz-decomp-corrupt-block
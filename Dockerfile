# Use Rust to build
FROM rustlang/rust:nightly as builder

# Add source code to the build stage.
ADD . /lz4-flex
WORKDIR /lz4-flex

RUN cargo install cargo-fuzz

# BUILD INSTRUCTIONS
WORKDIR /lz4-flex/fuzz
RUN cargo +nightly fuzz build fuzz_roundtrip && \
    cargo +nightly fuzz build fuzz_roundtrip_frame && \
    cargo +nightly fuzz build fuzz_decomp_corrupt_block
# Output binaries are placed in /lz4-flex/fuzz/target/x86_64-unknown-linux-gnu/release

# Package Stage -- we package for a plain Ubuntu machine
FROM --platform=linux/amd64 ubuntu:20.04

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y gcc

## Copy the binary from the build stage to an Ubuntu docker image
COPY --from=builder /lz4-flex/fuzz/target/x86_64-unknown-linux-gnu/release/fuzz_roundtrip /
COPY --from=builder /lz4-flex/fuzz/target/x86_64-unknown-linux-gnu/release/fuzz_roundtrip_frame /
COPY --from=builder /lz4-flex/fuzz/target/x86_64-unknown-linux-gnu/release/fuzz_decomp_corrupt_block /
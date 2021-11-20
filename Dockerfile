# We use the Jamsocket image to extract the binary, so that
# we can run `jamsocket build`.
FROM ghcr.io/drifting-in-space/jamsocket:main as jamsocket

# The main build step happens in the Rust image.
FROM rust:latest AS build

# We pull the jamsocket binary from the jamsocket image.
COPY --from=jamsocket /jamsocket /jamsocket

# Add the Rust targets we want to compile to.
RUN rustup target add wasm32-wasi
RUN rustup target add wasm32-unknown-unknown

# Clone Aper repo, which includes the Drop Four game.
WORKDIR /work
RUN git clone https://github.com/drifting-in-space/aper

# Build the demo game.
WORKDIR /work/aper/examples/drop-four
RUN /jamsocket build

# For the runtime image, we once again use the Jamsocket image,
# but now we copy the built artifacts into it. The Jamsocket
# image will run `jamsocket serve /dist` by default, so we
# put the built files there.
FROM ghcr.io/drifting-in-space/jamsocket:main

COPY --from=build /work/aper/examples/drop-four/dist /dist
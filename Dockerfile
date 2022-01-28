# We use the Jamsocket image to extract the binary, so that
# we can run `jamsocket build`.
FROM ghcr.io/drifting-in-space/stateroom:sha-f0411ef as stateroom

# The main build step happens in the Rust image.
FROM rust:latest AS build

# We pull the jamsocket binary from the jamsocket image.
COPY --from=stateroom /stateroom /stateroom

# Add the Rust targets we want to compile to.
RUN rustup target add wasm32-wasi
RUN rustup target add wasm32-unknown-unknown

# Clone Aper repo, which includes the Drop Four game.
WORKDIR /work
RUN git clone https://github.com/drifting-in-space/aper

# Build the demo game.
WORKDIR /work/aper/examples/drop-four
RUN /stateroom build

# For the runtime image, we once again use the Stateroom image,
# but now we copy the built artifacts into it. The Stateroom
# image will run `stateroom serve /dist` by default, so we
# put the built files there.
FROM ghcr.io/drifting-in-space/stateroom:main

COPY --from=build /work/aper/examples/drop-four/dist /dist
# Build
FROM swift:5.1 as builder
WORKDIR /ink
COPY . .
RUN mkdir -p /build/lib && cp -R /usr/lib/swift/linux/*.so* /build/lib
RUN swift build -c release && mv `swift build -c release --show-bin-path` /build/bin

# Release
FROM ubuntu:18.04
RUN apt-get -qq update \
    && apt-get install -y libatomic1 \
    && rm -r /var/lib/apt/lists/*
WORKDIR /ink
COPY --from=builder /build/bin/ink-cli .
COPY --from=builder /build/lib/* /usr/lib/
ENTRYPOINT ["./ink-cli"]

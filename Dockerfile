# Build stage
FROM rust:1.67 AS build

WORKDIR /usr/src/rust-server
COPY . .

RUN cargo install --path .

# Final stage
FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y openssl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/bin/
COPY --from=build /usr/local/cargo/bin/rust-server .

WORKDIR /app
COPY public/ public/

EXPOSE 3000

CMD ["rust-server"]

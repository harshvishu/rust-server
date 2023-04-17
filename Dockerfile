# Build stage
FROM rust:1.67 AS build

WORKDIR /usr/src/rust-server
COPY . .

RUN cargo install --path . && \
    strip /usr/local/cargo/bin/rust-server

# Final stage
FROM alpine:latest
ENV PUBLIC_PATH /app/public

RUN apk update && \
    apk add --no-cache openssl && \
    rm -rf /var/cache/apk/*

WORKDIR /usr/local/bin/
COPY --from=build /usr/local/cargo/bin/rust-server .

WORKDIR /app
COPY public public
RUN chmod -R 644 public

EXPOSE 3000

CMD ["rust-server"]

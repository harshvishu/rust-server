# Build stage
FROM rust:1.67 AS build

WORKDIR /usr/src/rust-server
COPY . .

RUN cargo install --path .

# Final stage
FROM alpine:latest AS final
ENV PUBLIC_PATH /app/public

RUN apk add --no-cache openssl ca-certificates && \
    update-ca-certificates && \
    rm -rf /var/cache/apk/*

WORKDIR /usr/local/bin/
COPY --from=build /usr/local/cargo/bin/rust-server .

RUN chmod +x rust-server && \
    if [ ! -f "/usr/local/bin/rust-server" ]; then echo "Error: rust-server binary not found"; exit 1; fi

WORKDIR /app
COPY public public
RUN chmod -R 644 public

EXPOSE 3000

CMD ["rust-server"]

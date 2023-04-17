FROM rust:1.67 as builder

RUN USER=root cargo new --bin rust-server

WORKDIR ./rust-server
COPY ./Cargo.toml ./Cargo.toml

RUN cargo build --release \
    && rm src/*.rs target/release/deps/rust_server*

ADD . ./

RUN cargo build --release


FROM debian:buster-slim

ARG APP=/usr/src/app

RUN apt-get update \
    && apt-get install -y ca-certificates tzdata \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 3000

ENV TZ=Etc/UTC \
    APP_USER=appuser

RUN groupadd $APP_USER \
    && useradd -g $APP_USER $APP_USER \
    && mkdir -p ${APP}

COPY --from=builder /rust-server/target/release/rust-server ${APP}/rust-server

RUN chown -R $APP_USER:$APP_USER ${APP}

USER $APP_USER
WORKDIR ${APP}

CMD ["./rust-server"]

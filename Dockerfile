# Build stage
FROM rust:1.43 as builder

WORKDIR /usr/src/rust-server

# Install dependencies for the project
RUN USER=root cargo init --bin .
COPY Cargo.toml Cargo.lock ./
RUN cargo build --release && rm src/*.rs

# Copy the rest of the source code and build the application
COPY src ./src
RUN rm -f target/release/deps/rust_server* \
    && cargo build --release

# Production stage
FROM debian:buster-slim

# Set the timezone and create a new user
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && groupadd -r appuser && useradd --no-log-init -r -g appuser appuser

ENV APP_USER=appuser \
    APP_HOME=/usr/src/app \
    TZ=Etc/UTC

# Install dependencies for the production environment
RUN apt-get update \
    && apt-get install --no-install-recommends -y ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy the built binary to the production environment
COPY --from=builder /usr/src/rust-server/target/release/rust-server ${APP_HOME}/rust-server

# Set ownership and permissions
RUN chown -R $APP_USER:$APP_USER ${APP_HOME} \
    && chmod 755 ${APP_HOME}

USER $APP_USER
WORKDIR ${APP_HOME}

# Start the application
CMD ["./rust-server"]

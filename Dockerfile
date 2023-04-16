FROM rust:1.67

WORKDIR /usr/src/myapp
COPY . .

RUN cargo install --path .

EXPOSE 3000

CMD ["rust-server"]

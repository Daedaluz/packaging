FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        curl \
        dpkg-dev \
        python3 \
	ca-certificates \
        gcc-arm-linux-gnueabihf \
        gcc-aarch64-linux-gnu  && \
    curl -fsSL https://deb.inits.se/x/sources/inits/dev | tee /etc/apt/sources.list.d/inits-dev.sources && \
    apt update && apt install golang/dev && \
    rm -rf /var/lib/apt/lists/*

RUN git config --global user.name "Builder" && \
    git config --global user.email "builder@localhost" && \
    git config --global safe.directory /

WORKDIR /src

CMD ["bash"]

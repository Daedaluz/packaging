FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        curl \
        dpkg-dev \
        python3 \
	openssh-client \
	ca-certificates \
        gcc-arm-linux-gnueabihf \
        gcc-aarch64-linux-gnu  && \
    curl -fsSL https://deb.inits.se/x/sources/inits/dev | tee /etc/apt/sources.list.d/inits-dev.sources && \
    apt update && apt install golang/dev gh && \
    rm -rf /var/lib/apt/lists/*

RUN git config --global user.name "Builder" && \
    git config --global user.email "builder@localhost" && \
    git config --global safe.directory /

COPY scripts/ /usr/bin/

WORKDIR /src

CMD ["bash"]

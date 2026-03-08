FROM golang:1.26.1-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        curl \
        dpkg-dev \
        python3 \
        gcc-arm-linux-gnueabihf \
        gcc-aarch64-linux-gnu \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY . .

RUN mkdir -p /out

CMD ["make", "all", "BUILD_DIR=/out"]

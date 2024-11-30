FROM ubuntu:24.04

ARG IDF_SYS_REVISION=denbeigh/validate
ARG IDF_SYS_REMOTE=https://github.com/denbeigh2000/esp-idf-sys
ENV IDF_SYS_REVISION=${IDF_SYS_REVISION}
ENV IDF_SYS_REMOTE=${IDF_SYS_REMOTE}

RUN apt-get update && \
    apt-get install -y sudo git curl ripgrep vim build-essential wget flex bison gperf python3 python3-pip python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0 && \
    apt-get clean && \
    useradd validation && \
    adduser validation sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    chsh -s /bin/bash validation && \
    mkdir -p /home/validation && chown validation:validation /home/validation

USER validation
ENV HOME /home/validation
WORKDIR /home/validation

ENV IDF_CHECKOUT "$HOME/esp/esp-idf"
ENV IDF_SYS_CHECKOUT "$HOME/esp-idf-sys"
ENV PATH "$HOME/tools:$PATH"

RUN bash -c "$(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs)" -- -y
COPY tools "$HOME/tools"

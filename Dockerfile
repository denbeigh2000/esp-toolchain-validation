FROM ubuntu:24.04@sha256:278628f08d4979fb9af9ead44277dbc9c92c2465922310916ad0c46ec9999295

RUN apt-get update && \
    apt-get install -y sudo git curl ripgrep vim build-essential wget flex bison gperf python3 python3-pip python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0 && \
    apt-get clean && \
    useradd validation && \
    adduser validation sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    chsh -s /bin/bash validation && \
    mkdir -p /home/validation/tools && chown -R validation:validation /home/validation

USER validation
ENV HOME /home/validation
WORKDIR /home/validation

# Rustup needs to be installed early
RUN bash -c "$(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs)" -- -y
# Required for next RUN
ENV IDF_CHECKOUT "$HOME/esp/esp-idf"
ENV IDF_SYS_CHECKOUT "$HOME/esp-idf-sys"
# Required for next RUN, defaults may change
ARG IDF_REVISION=release/v5.3
ARG IDF_SYS_REMOTE=https://github.com/denbeigh2000/esp-idf-sys
ARG IDF_SYS_REVISION=denbeigh/validate
ENV IDF_REVISION=${IDF_REVISION}
ENV IDF_SYS_REMOTE=${IDF_SYS_REMOTE}
ENV IDF_SYS_REVISION=${IDF_SYS_REVISION}
COPY tools/setup.sh "$HOME/tools/setup.sh"
# Clone repos, setup esp libs and rust toolchain, etc
RUN tools/setup.sh

# Not necessary for setup, but cheap and may potentially change
ENV PATH "$HOME/tools:$PATH"

# Cheap, fairly likely to change
COPY tools "$HOME/tools"

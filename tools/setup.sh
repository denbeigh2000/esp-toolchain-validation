#!/usr/bin/env bash

set -euo pipefail

mkdir -p "$IDF_CHECKOUT"
git clone https://github.com/espressif/esp-idf "$IDF_CHECKOUT"
git clone https://github.com/esp-rs/esp-idf-sys "$IDF_SYS_CHECKOUT"

IDF_SYS_REMOTE_NAME="denbeigh"

git -C "$IDF_CHECKOUT" fetch origin "$IDF_REVISION"
git -C "$IDF_CHECKOUT" checkout "$IDF_REVISION"
git -C "$IDF_CHECKOUT" submodule update --init --recursive
git -C "$IDF_SYS_CHECKOUT" remote add "$IDF_SYS_REMOTE_NAME" "$IDF_SYS_REMOTE"
git -C "$IDF_SYS_CHECKOUT" fetch "$IDF_SYS_REMOTE_NAME" "$IDF_SYS_REVISION"

export PATH="$(dirname $(find ~/.rustup/toolchains -maxdepth 3 -name cargo)):$HOME/.cargo/bin:$PATH"

"$HOME/.cargo/bin/cargo" install espup
"$HOME/.cargo/bin/cargo" install ldproxy
"$HOME/.cargo/bin/espup" install --name esp
"$IDF_CHECKOUT/install.sh" esp32

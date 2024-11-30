#!/usr/bin/env bash

set -euo pipefail

mkdir -p "$IDF_CHECKOUT"
git clone https://github.com/espressif/esp-idf "$IDF_CHECKOUT"
git clone https://github.com/esp-rs/esp-idf-sys "$IDF_SYS_CHECKOUT"

IDF_SYS_REMOTE_NAME="denbeigh"

git -C "$IDF_SYS_CHECKOUT" remote add "$IDF_SYS_REMOTE_NAME" "$IDF_SYS_REMOTE"
git -C "$IDF_SYS_CHECKOUT" fetch "$IDF_SYS_REMOTE_NAME" "$IDF_SYS_REVISION"
git -C "$IDF_SYS_CHECKOUT" checkout "$IDF_SYS_REVISION"

export PATH="$(dirname $(find ~/.rustup/toolchains -maxdepth 3 -name cargo)):$HOME/.cargo/bin:$PATH"

cargo install espup
"$HOME/.cargo/bin/espup" install --name esp
source "$HOME/export-esp.sh"

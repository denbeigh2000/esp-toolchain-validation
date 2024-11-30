#!/usr/bin/env bash

set -euo pipefail

ESP_RUST_TOOLCHAIN_DIR="$(find "$HOME/.rustup" -name esp)"
RUSTUP_DIR="$(realpath "$(dirname "$ESP_RUST_TOOLCHAIN_DIR")")"
STABLE_RUST_TOOLCHAIN_DIR="$(find "$RUSTUP_DIR" -maxdepth 1 -type d -name "*stable*")"
CARGO_DIR="$HOME/.cargo"

export PATH="$ESP_RUST_TOOLCHAIN_DIR/bin:$STABLE_RUST_TOOLCHAIN_DIR/bin:$CARGO_DIR/bin:$PATH"
source "$HOME/export-esp.sh"
source "$IDF_CHECKOUT/export.sh"

if [[ "${USE_CHANGES:-}" != "1" ]]
then
    echo '$USE_CHANGES = 1, using new config' >&2
    source "$IDF_CHECKOUT/export.sh"
else
    echo '$USE_CHANGES != 1, using stable config' >&2
fi

pushd "$IDF_SYS_CHECKOUT"
cargo clean
MCU=esp32 cargo build --target xtensa-esp32-espidf --example std_basics
popd

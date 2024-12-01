#!/usr/bin/env bash

set -euo pipefail

ESP_RUST_TOOLCHAIN_DIR="$(find "$HOME/.rustup" -name esp)"
RUSTUP_DIR="$(realpath "$(dirname "$ESP_RUST_TOOLCHAIN_DIR")")"
STABLE_RUST_TOOLCHAIN_DIR="$(find "$RUSTUP_DIR" -maxdepth 1 -type d -name "*stable*")"

git -C "$IDF_CHECKOUT" checkout "${RUNTIME_IDF_REVISION:-$IDF_REVISION}"
git -C "$IDF_CHECKOUT" submodule update --init --recursive
CARGO_DIR="$HOME/.cargo"

export PATH="$ESP_RUST_TOOLCHAIN_DIR/bin:$STABLE_RUST_TOOLCHAIN_DIR/bin:$CARGO_DIR/bin:$PATH"
source "$HOME/export-esp.sh"

REV="$IDF_SYS_REVISION"
if [[ "$USE_NEW_EMBUILD" = "0" ]]
then
    echo "\$USE_NEW_EMBUILD = $USE_NEW_EMBUILD, not using fork" >&2
    REV="master"
fi
git -C "$IDF_SYS_CHECKOUT" checkout "$REV"
git -C "$IDF_SYS_CHECKOUT" submodule update --init --recursive

if [[ "${USE_CHANGES:-}" != "1" ]]
then
    echo '$USE_CHANGES != 1, using stable config' >&2
else
    echo '$USE_CHANGES = 1, using new config' >&2
    "$IDF_CHECKOUT/install.sh" esp32
    source "$IDF_CHECKOUT/export.sh"
fi

if [[ "${MANGLE_GIT}" = "1" ]]
then
    echo "\$MANGLE_GIT = $MANGLE_GIT, mangling $IDF_SYS_CHECKOUT" >&2
    mangle-git.sh
fi


pushd "$IDF_SYS_CHECKOUT"
cargo clean
MCU=esp32 cargo build --target xtensa-esp32-espidf --example std_basics
popd

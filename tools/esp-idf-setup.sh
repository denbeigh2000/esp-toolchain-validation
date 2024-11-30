#!/usr/bin/env bash

set -euo pipefail

source "$HOME/export-esp.sh"
"$IDF_CHECKOUT/install.sh" esp32
source "$IDF_CHECKOUT/export.sh"

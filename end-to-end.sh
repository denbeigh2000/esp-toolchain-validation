#!/usr/bin/env bash

set -euo pipefail

WORKDIR="$(git rev-parse --show-toplevel)"
MANGLE_GIT="${MANGLE_GIT:-0}"
USE_LOCAL_IDF="${USE_LOCAL_IDF:-0}"
USE_NEW_EMBUILD="${USE_NEW_EMBUILD:-1}"

IDF_REVISION="release/v5.3"

err() {
    echo "$@" >&2
}

info() {
    changes_state="will not"
    if [[ "$USE_LOCAL_IDF" = "1" ]]
    then
        changes_state="will"
    fi

    git_mangle_state="will not"
    if [[ "$MANGLE_GIT" = "1" ]]
    then
        git_mangle_state="will"
    fi

    new_embuild_state="will not"
    if [[ "$USE_NEW_EMBUILD" != "0" ]]
    then
        new_embuild_state="will"
    fi

    echo
    echo "---"
    echo
    echo "MANGLE_GIT is set to $MANGLE_GIT"
    echo "Git $git_mangle_state be removed from IDF_PATH"
    echo
    echo "USE_LOCAL_IDF is set to $USE_LOCAL_IDF"
    echo "IDF_PATH $changes_state be set"
    echo
    echo "USE_NEW_EMBUILD is set to $USE_NEW_EMBUILD"
    echo "Forked embuild $new_embuild_state be used"
    echo
    echo "---"
    echo
}

SCRIPT_FILE="$(mktemp /tmp/esp-validation-bootstrap-XXXX)"
REMOTE_INFO_FILE="/home/validation/.info"

tee "$SCRIPT_FILE" >/dev/null <<-EOF
    #!/usr/bin/env bash

    cat "$REMOTE_INFO_FILE"

    set -euo pipefail

    test.sh
EOF


OUTPUT_DIR="/home/validation/esp-idf-sys/target/xtensa-esp32-espidf"
CONTAINER_NAME="$(mktemp -u esp-validation-XXXX)"
REMOTE_SCRIPT_FILE="/home/validation/entrypoint"
TAG_NAME="esp-validation-exp:latest"

cleanup() {
    docker rm -f "$CONTAINER_NAME"
}
trap cleanup EXIT

docker build \
    --build-arg "IDF_REVISION=$IDF_REVISION" \
    --tag "$TAG_NAME" \
    "$WORKDIR" 
info
# Ensure we don't exit early if this fails
set +e
docker run \
    --name "$CONTAINER_NAME" \
    --env "USE_LOCAL_IDF=$USE_LOCAL_IDF" \
    --env "MANGLE_GIT=$MANGLE_GIT" \
    --env "USE_NEW_EMBUILD=$USE_NEW_EMBUILD" \
    --env "RUNTIME_IDF_REVISION=$IDF_REVISION" \
    --interactive \
    --tty \
    "$TAG_NAME" \
    bash -c "$(<"$SCRIPT_FILE")"
set -e

BUILD_DIR="$(mktemp -d "$(pwd)/build-dir-XXX")"
docker cp "$CONTAINER_NAME:$OUTPUT_DIR" "$BUILD_DIR"
echo "Copied build directory to $BUILD_DIR"

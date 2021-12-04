#!/usr/bin/env bash

set -ex

OUTPUT_DIR=$(pwd)/output

rm -rf "${OUTPUT_DIR}" && mkdir "${OUTPUT_DIR}"

echo "Render"
render -o "${OUTPUT_DIR}" -b .
render -o "${OUTPUT_DIR}" -b .

echo "Skip"
render -o "${OUTPUT_DIR}" -b . -s
render -o "${OUTPUT_DIR}" -b . -s

rm -rf ${OUTPUT_DIR}

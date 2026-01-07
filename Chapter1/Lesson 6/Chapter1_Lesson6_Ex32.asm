#!/usr/bin/env bash
set -euo pipefail

need() {
  command -v "$1" > /dev/null 2>&1 || { echo "Missing tool: $1"; exit 1; }
}

need nasm
need ld
need objdump
need gdb

# Example major-version check (adjust to your standard)
NASM_VER="$(nasm -v | awk '{print $3}')"
NASM_MAJOR="${NASM_VER%%.*}"
if [ "$NASM_MAJOR" -lt 2 ]; then
  echo "NASM too old: $NASM_VER"
  exit 1
fi

echo "Toolchain OK: nasm=$NASM_VER"

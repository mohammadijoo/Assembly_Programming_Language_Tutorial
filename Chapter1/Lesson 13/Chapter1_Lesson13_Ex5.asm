#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD="${ROOT}/build"
mkdir -p "${BUILD}"

NASM="${NASM:-nasm}"
LD="${LD:-ld}"

# Assemble
"${NASM}" -f elf64 -g -F dwarf -I "${ROOT}/include/" \
  "${ROOT}/src/print_nasm.asm" -o "${BUILD}/print_nasm.o"

"${NASM}" -f elf64 -g -F dwarf -I "${ROOT}/include/" \
  "${ROOT}/src/main_nasm.asm" -o "${BUILD}/main_nasm.o"

# Link (no libc; entry is _start)
"${LD}" -o "${BUILD}/app_nasm" "${BUILD}/main_nasm.o" "${BUILD}/print_nasm.o"

echo "Built: ${BUILD}/app_nasm"

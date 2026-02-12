#!/bin/bash
# post_install.sh - Apply Linux compatibility patches after git clone --recursive
# This script is automatically called during installation on Linux systems.

FRANCINETTE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [ "$(uname)" = "Linux" ]; then
    echo "Applying Linux compatibility patches..."

    # Patch printfTester leaks.cpp (fix dlsym/malloc infinite recursion on glibc)
    PATCH_SRC="${FRANCINETTE_DIR}/patches/printf/printfTester/utils/leaks.cpp"
    PATCH_DST="${FRANCINETTE_DIR}/tests/printf/printfTester/utils/leaks.cpp"
    if [ -f "${PATCH_SRC}" ] && [ -d "$(dirname "${PATCH_DST}")" ]; then
        cp "${PATCH_SRC}" "${PATCH_DST}"
        echo "  Patched: printfTester/utils/leaks.cpp"
    fi

    echo "Linux patches applied."
fi

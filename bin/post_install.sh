#!/bin/bash
# post_install.sh - Apply Linux compatibility patches after git clone --recursive
# This script is automatically called during installation on Linux systems.

FRANCINETTE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [ "$(uname)" = "Linux" ]; then
    echo "Applying Linux compatibility patches..."

    # Patch printfTester leaks.cpp (fix dlsym/malloc infinite recursion on glibc)
    SRC="${FRANCINETTE_DIR}/patches/printf/printfTester/utils/leaks.cpp"
    DST="${FRANCINETTE_DIR}/tests/printf/printfTester/utils/leaks.cpp"
    if [ -f "${SRC}" ] && [ -d "$(dirname "${DST}")" ]; then
        cp "${SRC}" "${DST}"
        echo "  Patched: printfTester/utils/leaks.cpp"
    fi

    # Patch printfTester Makefile (add valgrind suppression for C++ init leak)
    SRC="${FRANCINETTE_DIR}/patches/printf/printfTester/Makefile"
    DST="${FRANCINETTE_DIR}/tests/printf/printfTester/Makefile"
    if [ -f "${SRC}" ] && [ -d "$(dirname "${DST}")" ]; then
        cp "${SRC}" "${DST}"
        echo "  Patched: printfTester/Makefile"
    fi

    # Copy valgrind suppression file
    SRC="${FRANCINETTE_DIR}/patches/printf/printfTester/utils/libcpp.supp"
    DST="${FRANCINETTE_DIR}/tests/printf/printfTester/utils/libcpp.supp"
    if [ -f "${SRC}" ] && [ -d "$(dirname "${DST}")" ]; then
        cp "${SRC}" "${DST}"
        echo "  Added: printfTester/utils/libcpp.supp"
    fi

    # Patch fsoares pf_utils.c (stderr fallback when /dev/tty unavailable)
    SRC="${FRANCINETTE_DIR}/patches/printf/fsoares/pf_utils.c"
    DST="${FRANCINETTE_DIR}/tests/printf/fsoares/pf_utils.c"
    if [ -f "${SRC}" ] && [ -d "$(dirname "${DST}")" ]; then
        cp "${SRC}" "${DST}"
        echo "  Patched: fsoares/pf_utils.c"
    fi

    echo "Linux patches applied."
fi

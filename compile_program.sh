#!/usr/bin/env sh

set -eu

usage() {
    echo "Usage: $0 SOURCE.S [OUTPUT.hex]" >&2
    echo "       OUTPUT.hex defaults to program.hex" >&2
}

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    usage
    exit 2
fi

source_file=$1
output_file=${2:-program.hex}

if [ ! -f "$source_file" ]; then
    echo "error: source file '$source_file' does not exist" >&2
    exit 1
fi

case "$source_file" in
    *.S) ;;
    *)
        echo "error: source must have a .S extension" >&2
        exit 1
        ;;
esac

if [ -n "${CC:-}" ]; then
    compiler=$CC
    case ${compiler##*/} in
        clang*) compiler_kind=clang ;;
        *) compiler_kind=gnu ;;
    esac
elif command -v riscv32-unknown-elf-gcc >/dev/null 2>&1; then
    compiler=riscv32-unknown-elf-gcc
    compiler_kind=gnu
elif command -v riscv64-unknown-elf-gcc >/dev/null 2>&1; then
    compiler=riscv64-unknown-elf-gcc
    compiler_kind=gnu
elif command -v clang >/dev/null 2>&1 && command -v ld.lld >/dev/null 2>&1; then
    compiler=clang
    compiler_kind=clang
else
    echo "error: a RISC-V GCC toolchain or Clang with ld.lld is required" >&2
    exit 127
fi

if [ -n "${OBJCOPY:-}" ]; then
    objcopy=$OBJCOPY
elif [ "$compiler_kind" = gnu ]; then
    compiler_prefix=${compiler%gcc}
    if command -v "${compiler_prefix}objcopy" >/dev/null 2>&1; then
        objcopy=${compiler_prefix}objcopy
    elif command -v llvm-objcopy >/dev/null 2>&1; then
        objcopy=llvm-objcopy
    else
        echo "error: RISC-V objcopy or llvm-objcopy is required" >&2
        exit 127
    fi
elif command -v llvm-objcopy >/dev/null 2>&1; then
    objcopy=llvm-objcopy
else
    echo "error: llvm-objcopy is required when compiling with Clang" >&2
    exit 127
fi

build_dir=$(mktemp -d "${TMPDIR:-/tmp}/rv32i-hex.XXXXXX")
cleanup() {
    rm -rf "$build_dir"
}
trap cleanup EXIT HUP INT TERM

elf_file="$build_dir/program.elf"
binary_file="$build_dir/program.bin"
hex_file="$build_dir/program.hex"

common_flags="-march=rv32i -mabi=ilp32 -nostdlib -Wl,--no-relax -Wl,-e,_start"

if [ "$compiler_kind" = clang ]; then
    # The zero image base keeps absolute addresses consistent with this CPU's
    # instruction memory, which starts at address 0.
    # shellcheck disable=SC2086
    "$compiler" --target=riscv32-unknown-elf -fuse-ld=lld $common_flags \
        -Wl,-Ttext=0 -Wl,--image-base=0 -o "$elf_file" "$source_file"
else
    # CC may name a custom GCC-compatible RISC-V compiler.
    # shellcheck disable=SC2086
    "$compiler" $common_flags -Wl,-Ttext=0 -o "$elf_file" "$source_file"
fi

"$objcopy" -O binary --only-section=.text "$elf_file" "$binary_file"

byte_count=$(wc -c < "$binary_file")
byte_count=$(printf '%s' "$byte_count" | tr -d '[:space:]')
if [ "$byte_count" -eq 0 ]; then
    echo "error: compiled .text section is empty" >&2
    exit 1
fi
if [ $((byte_count % 4)) -ne 0 ]; then
    echo "error: compiled .text size ($byte_count bytes) is not word-aligned" >&2
    exit 1
fi

# $readmemh expects each instruction as a 32-bit numeric word. RISC-V stores
# those words little-endian in the binary, so reverse each group of four bytes.
od -An -v -t x1 "$binary_file" | awk '
{
    for (i = 1; i <= NF; i++) {
        bytes[count % 4] = $i
        count++
        if (count % 4 == 0)
            print bytes[3] bytes[2] bytes[1] bytes[0]
    }
}
' > "$hex_file"

output_dir=$(dirname "$output_file")
if [ ! -d "$output_dir" ]; then
    echo "error: output directory '$output_dir' does not exist" >&2
    exit 1
fi

mv "$hex_file" "$output_file"
echo "Wrote $output_file ($((byte_count / 4)) instructions)."

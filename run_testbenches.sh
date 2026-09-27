#!/usr/bin/env bash
set -uo pipefail

readonly TESTBENCH_DIR="testbenches"
readonly BUILD_DIR="${TMPDIR:-/tmp}/rv-testbenches-$$"

cleanup() {
  rm -rf "$BUILD_DIR"
}
trap cleanup EXIT

if ! command -v iverilog >/dev/null 2>&1; then
  echo "error: iverilog is required but was not found in PATH" >&2
  exit 127
fi

if [[ ! -d "$TESTBENCH_DIR" ]]; then
  echo "error: testbench directory '$TESTBENCH_DIR' does not exist" >&2
  exit 1
fi

mapfile -d '' testbenches < <(find "$TESTBENCH_DIR" -type f \( -name 'tb_*.sv' -o -name 'tb_*.v' \) -print0 | sort -z)
mapfile -d '' design_sources < <(find . -path "./$TESTBENCH_DIR" -prune -o -type f \( -name '*.sv' -o -name '*.v' \) -print0 | sort -z)

if ((${#testbenches[@]} == 0)); then
  echo "No testbenches matching $TESTBENCH_DIR/tb_*.{sv,v} found."
  exit 0
fi

mkdir -p "$BUILD_DIR"
failures=0

for testbench in "${testbenches[@]}"; do
  filename=$(basename "$testbench")
  top_module=${filename%.*}
  executable="$BUILD_DIR/$top_module"

  echo "==> $testbench"
  if ! iverilog -g2012 -s "$top_module" -o "$executable" "${design_sources[@]}" "$testbench"; then
    ((failures += 1))
    echo "FAIL: compilation failed for $testbench" >&2
    continue
  fi

  if ! vvp "$executable"; then
    ((failures += 1))
    echo "FAIL: simulation failed for $testbench" >&2
  fi
done

if ((failures > 0)); then
  echo "$failures testbench(es) failed." >&2
  exit 1
fi

echo "All ${#testbenches[@]} testbench(es) passed."

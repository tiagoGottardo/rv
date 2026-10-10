#!/usr/bin/env bash
set -uo pipefail

readonly TEST_DIR="test"
readonly BUILD_DIR="${TMPDIR:-/tmp}/rv-tests-$$"

cleanup() {
  rm -rf "$BUILD_DIR"
}
trap cleanup EXIT

if ! command -v iverilog >/dev/null 2>&1; then
  echo "error: iverilog is required but was not found in PATH" >&2
  exit 127
fi

if [[ ! -d "$TEST_DIR" ]]; then
  echo "error: test directory '$TEST_DIR' does not exist" >&2
  exit 1
fi

mapfile -d '' tests < <(find "$TEST_DIR" -type f \( -name 'test_*.sv' -o -name 'test_*.v' \) -print0 | sort -z)
mapfile -d '' design_sources < <(find . -path "./$TEST_DIR" -prune -o -type f \( -name '*.sv' -o -name '*.v' \) -print0 | sort -z)

if ((${#tests[@]} == 0)); then
  echo "No tests matching $TEST_DIR/test_*.{sv,v} found."
  exit 0
fi

mkdir -p "$BUILD_DIR"
failures=0

for test in "${tests[@]}"; do
  filename=$(basename "$test")
  top_module=${filename%.*}
  executable="$BUILD_DIR/$top_module"

  echo "==> $test"
  if ! iverilog -g2012 -s "$top_module" -o "$executable" "${design_sources[@]}" "$test"; then
    ((failures += 1))
    echo "FAIL: compilation failed for $test" >&2
    continue
  fi

  if ! vvp "$executable"; then
    ((failures += 1))
    echo "FAIL: simulation failed for $test" >&2
  fi
done

if ((failures > 0)); then
  echo "$failures test(s) failed." >&2
  exit 1
fi

echo "All ${#tests[@]} test(s) passed."

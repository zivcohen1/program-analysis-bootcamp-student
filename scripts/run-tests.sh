#!/usr/bin/env bash
set -euo pipefail

echo "=== Running All Solution Tests ==="
echo ""

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PASS=0
FAIL=0

# Helper: swap a dune (dirs ...) file to use solution/ instead of starter/
swap_to_solution() {
    local dune_file="$1"
    if [ -f "$dune_file" ]; then
        sed -i.bak 's/dirs starter/dirs solution/' "$dune_file"
    fi
}

# Helper: restore a dune (dirs ...) file back to starter/
restore_to_starter() {
    local dune_file="$1"
    if [ -f "$dune_file.bak" ]; then
        mv "$dune_file.bak" "$dune_file"
    fi
}

cd "$ROOT_DIR"

# Build shared library first
echo "--- Building shared_ast library ---"
opam exec -- dune build lib/shared_ast/ 2>/dev/null && echo "[OK]" || echo "[SKIP]"
echo ""

# Module 2 exercises
for ex_dir in "$ROOT_DIR"/modules/module2-ast/exercises/*/; do
    if [ -d "$ex_dir/solution" ] && [ -d "$ex_dir/tests" ]; then
        name="Module 2: $(basename "$ex_dir")"
        echo "--- $name ---"

        # These exercises use (dirs ...) in the exercise dune file
        dune_file="$ex_dir/dune"
        swap_to_solution "$dune_file"

        if opam exec -- dune runtest "$ex_dir" 2>&1 | tail -3; then
            PASS=$((PASS + 1))
        else
            FAIL=$((FAIL + 1))
        fi

        restore_to_starter "$dune_file"
        echo ""
    fi
done

# Module 3 exercises
for ex_dir in "$ROOT_DIR"/modules/module3-static-analysis/exercises/*/; do
    if [ -d "$ex_dir/solution" ] && [ -d "$ex_dir/tests" ]; then
        name="Module 3: $(basename "$ex_dir")"
        echo "--- $name ---"

        dune_file="$ex_dir/dune"
        swap_to_solution "$dune_file"

        if opam exec -- dune runtest "$ex_dir" 2>&1 | tail -3; then
            PASS=$((PASS + 1))
        else
            FAIL=$((FAIL + 1))
        fi

        restore_to_starter "$dune_file"
        echo ""
    fi
done

# Labs
for lab_dir in "$ROOT_DIR"/labs/*/; do
    if [ -d "$lab_dir/solution" ] && [ -d "$lab_dir/grading" ]; then
        name="Lab: $(basename "$lab_dir")"
        echo "--- $name ---"

        dune_file="$lab_dir/dune"
        swap_to_solution "$dune_file"

        if opam exec -- dune runtest "$lab_dir" 2>&1 | tail -3; then
            PASS=$((PASS + 1))
        else
            FAIL=$((FAIL + 1))
        fi

        restore_to_starter "$dune_file"
        echo ""
    fi
done

echo "=== Results: $PASS passed, $FAIL failed ==="
[ $FAIL -eq 0 ] || exit 1

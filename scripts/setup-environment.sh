#!/usr/bin/env bash
set -euo pipefail

echo "=== Program Analysis Bootcamp - Environment Setup ==="
echo ""

ERRORS=0

# Check OCaml
if command -v ocaml &>/dev/null; then
    OCAML_VERSION=$(ocaml -version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    OCAML_MINOR=$(echo "$OCAML_VERSION" | cut -d. -f2)
    if [ "$OCAML_MINOR" -ge 14 ]; then
        echo "[OK] OCaml $OCAML_VERSION"
    else
        echo "[FAIL] OCaml 4.14+ required, found $OCAML_VERSION"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "[FAIL] OCaml not found. Install via opam: https://opam.ocaml.org/doc/Install.html"
    ERRORS=$((ERRORS + 1))
fi

# Check opam
if command -v opam &>/dev/null; then
    OPAM_VERSION=$(opam --version)
    echo "[OK] opam $OPAM_VERSION"
else
    echo "[FAIL] opam not found. Install from https://opam.ocaml.org/doc/Install.html"
    ERRORS=$((ERRORS + 1))
fi

# Check dune
if command -v dune &>/dev/null || opam exec -- dune --version &>/dev/null 2>&1; then
    DUNE_VERSION=$(opam exec -- dune --version 2>/dev/null || dune --version)
    echo "[OK] dune $DUNE_VERSION"
else
    echo "[INFO] Installing dune..."
    opam install dune -y
    echo "[OK] dune installed"
fi

# Check ounit2
if opam list ounit2 --installed --short &>/dev/null 2>&1; then
    echo "[OK] ounit2 installed"
else
    echo "[INFO] Installing ounit2..."
    opam install ounit2 -y
    echo "[OK] ounit2 installed"
fi

# Check menhir
if opam list menhir --installed --short &>/dev/null 2>&1; then
    echo "[OK] menhir installed"
else
    echo "[INFO] Installing menhir..."
    opam install menhir -y
    echo "[OK] menhir installed"
fi

# Check Node.js (needed for Module 1)
if command -v node &>/dev/null; then
    NODE_VERSION=$(node -v | sed 's/v//')
    NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)
    if [ "$NODE_MAJOR" -ge 16 ]; then
        echo "[OK] Node.js $NODE_VERSION"
    else
        echo "[WARN] Node.js 16+ recommended, found $NODE_VERSION (needed for Module 1)"
    fi
else
    echo "[WARN] Node.js not found. Required for Module 1 exercises. Install from https://nodejs.org"
fi

# Check git
if command -v git &>/dev/null; then
    echo "[OK] git $(git --version | awk '{print $3}')"
else
    echo "[FAIL] git not found"
    ERRORS=$((ERRORS + 1))
fi

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "=== Setup complete! All requirements met. ==="
else
    echo "=== Setup incomplete: $ERRORS issue(s) found. Please fix before proceeding. ==="
    exit 1
fi

# OCaml Setup Guide

## Requirements

- **OCaml 4.14 or higher** (5.x recommended)
- **opam** (OCaml package manager)
- **dune** (build system)
- **ounit2** (testing framework)
- **menhir** (parser generator, for Lab 2)

## Installation

### macOS

```bash
# Install opam via Homebrew
brew install opam

# Initialize opam (first time only)
opam init -y
eval $(opam env)

# Install OCaml compiler
opam switch create 5.1.0
eval $(opam env)

# Install required packages
opam install dune ounit2 menhir -y
```

### Ubuntu / Debian

```bash
# Install opam
sudo apt update
sudo apt install opam

# Initialize opam
opam init -y
eval $(opam env)

# Install OCaml compiler
opam switch create 5.1.0
eval $(opam env)

# Install required packages
opam install dune ounit2 menhir -y
```

### Windows (WSL recommended)

1. Install WSL2 with Ubuntu from the Microsoft Store
2. Follow the Ubuntu instructions above inside WSL

Alternatively, use the OCaml for Windows installer from [fdopen.github.io/opam-repository-mingw](https://fdopen.github.io/opam-repository-mingw/).

## Verifying Your Setup

```bash
# Check OCaml version
ocaml -version

# Check dune
dune --version

# Check opam packages
opam list ounit2 menhir

# Build the shared library from the repository root
cd program-analysis-bootcamp
dune build lib/shared_ast/
```

## Building and Testing

```bash
# Build everything
dune build

# Run all tests
dune runtest

# Run tests for a specific exercise
dune runtest modules/module2-ast/exercises/traversal-algorithms/

# Build and run a specific executable
dune exec modules/module2-ast/exercises/ast-structure-mapping/starter/ast_visualizer.exe
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `ocaml: command not found` | Run `eval $(opam env)` or add to your shell profile |
| `dune: command not found` | `opam install dune` then `eval $(opam env)` |
| `Error: Unbound module OUnit2` | `opam install ounit2` |
| `Error: menhir not found` | `opam install menhir` |
| opam switch errors | `opam switch create 5.1.0` and `eval $(opam env)` |
| Duplicate library name | Only one of starter/ or solution/ can be active; check the `dune` file's `(dirs ...)` setting |

# Lab 1: Tool Setup and Verification

## Overview
This lab ensures your development environment is properly configured for the bootcamp.

## Checklist

- [ ] Python 3.8+ installed
- [ ] Node.js 16+ installed (for Module 1)
- [ ] Git configured
- [ ] pytest installed (`pip install pytest`)
- [ ] ESLint available (`npm install -g eslint` or via npx)
- [ ] Code editor ready (VS Code recommended)
- [ ] Repository cloned

## Quick Setup

```bash
# From the repository root
./scripts/setup-environment.sh

# Or run the verification script
python labs/lab1-tool-setup/verify_setup.py
```

## Verification Steps

1. Run `python labs/lab1-tool-setup/verify_setup.py`
2. Ensure all checks pass
3. If any check fails, follow the installation guide for your platform:
   - [Python Setup](../../resources/tools/installation-guides/python-setup.md)
   - [Node.js Setup](../../resources/tools/installation-guides/node-setup.md)

## Troubleshooting

### Python not found
Install from [python.org](https://www.python.org/downloads/). Make sure to add Python to PATH.

### Node.js not found
Install from [nodejs.org](https://nodejs.org/). The LTS version is recommended.

### pytest not installed
```bash
pip install pytest
# or
pip3 install pytest
```

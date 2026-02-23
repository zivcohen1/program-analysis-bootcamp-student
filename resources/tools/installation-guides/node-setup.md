# Node.js Setup Guide

## Requirements

- **Node.js 16 or higher** (18+ recommended)
- **npm** (bundled with Node.js)

Node.js is only required for **Module 1** (calculator-bugs exercise with ESLint).

## Installation

### macOS

```bash
# Check if Node.js is installed
node --version

# Install via Homebrew
brew install node@18

# Or use nvm (recommended for managing versions)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 18
nvm use 18
```

### Ubuntu / Debian

```bash
# Using NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install nodejs
```

### Windows

1. Download from [nodejs.org](https://nodejs.org/) (LTS version recommended)
2. Run the installer
3. Verify: `node --version` and `npm --version`

## Module 1 Exercise Setup

Navigate to the calculator-bugs exercise and install dependencies:

```bash
cd modules/module1-foundations/exercises/calculator-bugs/starter
npm install
```

This installs ESLint and its dependencies locally.

## Running ESLint

```bash
# Run the linter
npx eslint calculator.js

# Run tests
node test-calculator.js
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `node: command not found` | Install Node.js or add to PATH |
| `npm ERR! EACCES` | Fix permissions: `npm config set prefix ~/.npm-global` |
| ESLint version conflicts | Delete `node_modules` and `package-lock.json`, then `npm install` |
| `nvm: command not found` | Restart your terminal after installing nvm |

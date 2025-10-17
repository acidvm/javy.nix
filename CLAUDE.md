# Claude AI Development Guide

Welcome Claude! This document provides quick reference for contributing to the javy.nix project.

## Getting Started

For comprehensive development guidelines, please refer to:
- 📖 **[AGENTS.md](./AGENTS.md)** - Complete development workflow and testing procedures

## Quick Reference

### Essential Workflow
1. Branch from `origin/main`
2. Test with `nix flake check`
3. Push and create PR with `gh`

### Key Commands
```bash
# Create feature branch
git checkout -b feat/feature-name origin/main

# Test your changes
nix flake check
nix build

# Create pull request
gh pr create
```

## Project Overview

This project provides a Nix flake for Javy, a JavaScript to WebAssembly toolchain. The flake:
- Downloads pre-built Javy binaries from GitHub releases
- Supports multiple platforms (Linux/macOS, x86_64/ARM)
- Provides package, app, and devShell outputs

## CI/CD

All PRs are automatically tested on:
- Ubuntu 24.04
- macOS 15

Using:
- Determinate Nix installer
- FlakeHub caching

## Need Help?

Refer to [AGENTS.md](./AGENTS.md) for:
- Detailed development workflow
- Testing requirements
- Troubleshooting guide
- Best practices
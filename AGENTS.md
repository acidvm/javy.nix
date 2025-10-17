# Development Guide for AI Agents

This guide provides instructions for AI agents (like Claude, Cursor, or GitHub Copilot) to effectively contribute to this project.

## Quick Start

When implementing features or fixes:

1. **Always branch from origin/main**
2. **Test locally before pushing**
3. **Create descriptive pull requests**

## Development Workflow

### 1. Create a Feature Branch

Always create a new feature branch from the latest `origin/main`:

```bash
# Fetch latest changes
git fetch origin

# Create and checkout new branch from origin/main
git checkout -b feat/your-feature-name origin/main
# or for docs: docs/your-doc-name
# or for fixes: fix/your-fix-name
```

### 2. Make Changes

- Edit files as needed for your feature
- Follow existing code patterns and style
- Keep changes focused and atomic

### 3. Test Your Changes

Before committing, always test your changes:

```bash
# Run flake check to validate the Nix configuration
nix flake check

# Build the package to ensure it compiles
nix build

# Test the binary works
./result/bin/javy --help
```

### 4. Commit Your Changes

Create meaningful commit messages following [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format:

```bash
# Stage your changes
git add .

# Commit with a descriptive message using Conventional Commits format
git commit -m "feat: add your feature description

- Detail important changes
- Explain why the change was made
- Reference any issues if applicable"
```

Conventional Commits format: `<type>[optional scope]: <description>`
- Use lowercase for the description
- Types: feat, fix, docs, style, refactor, test, chore, ci

### 5. Push and Create Pull Request

Push your branch and create a PR using GitHub CLI:

```bash
# Push your branch to remote
git push -u origin your-branch-name

# Create pull request using gh
gh pr create --title "Your PR title" --body "## Summary
- What this PR does
- Why it's needed

## Changes
- List specific changes

## Testing
- How to test these changes
- What was tested"
```

## Branch Naming Conventions

- `feat/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `chore/` - Maintenance tasks
- `ci/` - CI/CD related changes

## Testing Requirements

All changes must pass:

1. **Nix flake check** - Validates the flake configuration
2. **Build test** - Ensures the package builds successfully
3. **CI checks** - GitHub Actions must pass on Ubuntu and macOS

## CI/CD Pipeline

Our CI pipeline automatically:

- Runs on every push and pull request
- Tests on Ubuntu 24.04 and macOS 15
- Validates the Nix flake
- Builds the package
- Tests the binary execution

## Best Practices for AI Agents

1. **Verify branch state**: Always check current branch before making changes
   ```bash
   git branch --show-current
   git status
   ```

2. **Keep PRs focused**: One feature or fix per PR

3. **Test incrementally**: Run `nix flake check` after significant changes

4. **Document changes**: Update relevant documentation when adding features

5. **Use Conventional Commits**: Follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format
   - `feat:` for features (new functionality)
   - `fix:` for bug fixes
   - `docs:` for documentation changes
   - `style:` for formatting, missing semi-colons, etc.
   - `refactor:` for code changes that neither fix bugs nor add features
   - `test:` for adding or correcting tests
   - `chore:` for maintenance tasks
   - `ci:` for CI/CD changes
   - Use lowercase for descriptions

## Common Commands Reference

```bash
# Check current branch
git branch --show-current

# See uncommitted changes
git status

# Test the flake
nix flake check

# Build the package
nix build

# Run the built binary
./result/bin/javy --version

# Create a PR
gh pr create

# List recent PRs
gh pr list

# Check CI status
gh run list --limit 5
```

## Troubleshooting

### Flake Check Fails
- Ensure all Nix syntax is correct
- Check that all referenced files exist
- Verify SHA256 hashes are correct

### Build Fails
- Check network connectivity for downloads
- Verify platform-specific configurations
- Ensure all dependencies are specified

### CI Fails
- Review the GitHub Actions logs
- Check both Ubuntu and macOS results
- Ensure the workflow file syntax is correct

## Questions?

If you encounter issues not covered here, check:
- Existing pull requests for similar changes
- GitHub Issues for known problems
- The CI workflow logs for error details
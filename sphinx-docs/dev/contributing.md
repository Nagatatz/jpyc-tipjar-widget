# Contributing Guide

Thank you for your interest in contributing!

## Getting Started

1. Fork the repository on GitHub
2. Clone your fork:
   ```bash
   git clone https://github.com/<your-username>/jpyc-tipjar-widget.git
   ```
3. Set up your [development environment](setup.md)
4. Create a feature branch:
   ```bash
   git checkout -b feature/my-feature
   ```

## Development Workflow

### Branch Naming

| Prefix | Use |
|--------|-----|
| `feature/` | New features |
| `fix/` | Bug fixes |
| `refactor/` | Code refactoring |
| `docs/` | Documentation |
| `test/` | Test additions |
| `chore/` | Configuration, dependencies |

### Commit Messages

Use emoji prefixes for commit messages:

| Emoji | Use |
|-------|-----|
| ✨ | New feature |
| 🐛 | Bug fix |
| ♻️ | Refactoring |
| 📝 | Documentation |
| 🔧 | Configuration change |
| ✅ | Test addition/fix |

**Format:** `<emoji> <verb> <concise description>`

## Submitting Changes

1. Ensure all tests pass
2. Ensure code style checks pass
3. Build the project
4. Push your branch and create a Pull Request

### PR Guidelines

- Keep PRs focused on a single feature or fix
- Write a clear description of what changed and why
- Reference related issues if applicable

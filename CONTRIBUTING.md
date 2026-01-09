# Contributing to OutfitStyle

Thank you for your interest in contributing to OutfitStyle! We welcome contributions from everyone.

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Style](#code-style)
- [Testing](#testing)
- [Pull Requests](#pull-requests)
- [Issue Guidelines](#issue-guidelines)

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/outfitstyle.git`
3. Create a new branch: `git checkout -b feature/your-feature-name`
4. Follow the [Quick Start](README.md#quick-start) instructions to set up your development environment

## Development Workflow

### Backend (Go)

1. Make sure you have Go 1.21+ installed
2. Run tests: `go test ./...`
3. Format code: `go fmt ./...`
4. Run linter: `golangci-lint run`

### Frontend (Flutter)

1. Make sure you have Flutter SDK installed
2. Run tests: `flutter test`
3. Format code: `flutter format .`
4. Analyze code: `flutter analyze`

### ML Service (Python)

1. Make sure you have Python 3.11+ installed
2. Run tests: `python -m pytest tests/`
3. Format code: `black .`
4. Run linter: `ruff check .`

## Code Style

### Go
- Follow [Effective Go](https://golang.org/doc/effective_go.html)
- Use `gofmt` for formatting
- Write clear, documented code
- Add tests for new functionality

### Flutter/Dart
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `flutter format` for formatting
- Follow Riverpod best practices
- Write widget tests for UI components

### Python
- Follow [PEP 8](https://pep8.org/)
- Use `black` for formatting
- Use `mypy` for type checking
- Write docstrings for functions

## Testing

### Backend Tests
- Write unit tests for business logic
- Write integration tests for database operations
- Aim for >70% test coverage
- Use table-driven tests where appropriate

### Frontend Tests
- Write unit tests for providers/state notifiers
- Write widget tests for UI components
- Write integration tests for critical user flows
- Use golden tests for UI regression

### ML Service Tests
- Write unit tests for ML algorithms
- Write integration tests for API endpoints
- Test edge cases and error conditions
- Test performance with realistic datasets

## Pull Requests

1. Create a descriptive title and detailed description
2. Link to any related issues
3. Include screenshots for UI changes
4. Make sure all tests pass
5. Request review from maintainers
6. Address feedback promptly

### PR Template

```markdown
## Summary
Brief description of changes

## Changes
- Change 1
- Change 2
- Change 3

## Testing
- [ ] Tests pass locally
- [ ] New functionality tested
- [ ] Existing functionality still works
- [ ] UI changes tested on multiple devices

## Related Issues
Fixes #issue-number
```

## Issue Guidelines

### Good Issues Include:
- Clear, descriptive title
- Detailed description of the problem
- Steps to reproduce (for bugs)
- Expected vs actual behavior
- Screenshots if applicable
- Environment information (OS, browser, version)

### Before Submitting:
- Search existing issues
- Check if the issue is reproducible
- Consider if you can fix it yourself

## Code of Conduct

Please follow our [Code of Conduct](CODE_OF_CONDUCT.md) in all interactions.

## Questions?

Feel free to reach out to the maintainers or ask questions in the issue tracker.
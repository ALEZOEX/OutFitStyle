# Contributing to OutfitStyle

Thank you for your interest in contributing to OutfitStyle! We welcome contributions from the community.

## Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

## How to Contribute

### Reporting Bugs

- Ensure the bug was not already reported by searching on GitHub under [Issues](https://github.com/your-username/outfitstyle/issues).
- If you're unable to find an open issue addressing the problem, [open a new one](https://github.com/your-username/outfitstyle/issues/new). Be sure to include a **title and clear description**, as much relevant information as possible, and a **code sample** or an **executable test case** demonstrating the expected behavior that is not occurring.

### Suggesting Enhancements

- Open a new issue with a clear title and detailed description of the suggested enhancement.
- Provide examples of how the enhancement would be used.
- Explain why this enhancement would be useful to most OutfitStyle users.

### Pull Requests

1. Fork the repository
2. Create a new branch for your feature or bug fix
3. Make your changes
4. Add or update tests as necessary
5. Ensure all tests pass
6. Update documentation if needed
7. Submit a pull request

### Development Setup

1. Clone your fork of the repository
2. Install dependencies for each service:
   - For Go service: `cd server && go mod tidy`
   - For ML service: `cd server/ml-service && pip install -r requirements.txt`
3. Set up environment variables using the `.env.example` files
4. Run tests to ensure everything works: `make test`

### Code Style

- Follow the existing code style in the project
- Write clear, concise commit messages
- Add comments to explain complex code
- Write unit tests for new functionality

### Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line

## Architecture Overview

OutfitStyle uses a microservices architecture:

1. **Go API Server** - Main backend service handling REST API requests
2. **ML Service** - Python-based machine learning service for outfit recommendations
3. **Marketplace Service** - Service for integrating with clothing marketplaces
4. **Flutter Client** - Mobile and web client

## Getting Help

If you need help, you can:

- Open an issue with the "question" label
- Contact the maintainers directly

Thank you for contributing!
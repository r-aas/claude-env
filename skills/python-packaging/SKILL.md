---
name: python-packaging
description: Create distributable Python packages using uv for dependency management. Use when packaging Python libraries, creating CLI tools, or distributing Python code. Covers project structure, pyproject.toml, and publishing to PyPI.
---

# Python Packaging with uv

Create Python packages using modern tooling. **uv only - no pip, no venv, no virtualenv.**

## Quick Start

```bash
# Create new package
uv init my-package
cd my-package

# Add dependencies
uv add requests click pydantic

# Add dev dependencies
uv add --dev pytest ruff mypy

# Run tests
uv run pytest
```

## Project Structure

### Recommended: src Layout

```
my-package/
├── pyproject.toml      # All configuration here
├── README.md
├── LICENSE
├── src/
│   └── my_package/
│       ├── __init__.py
│       ├── core.py
│       └── py.typed     # For type hints
└── tests/
    └── test_core.py
```

### Minimal pyproject.toml

```toml
[project]
name = "my-package"
version = "0.1.0"
description = "A short description"
authors = [{name = "Your Name", email = "you@example.com"}]
readme = "README.md"
requires-python = ">=3.10"
dependencies = [
    "requests>=2.28.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "ruff>=0.1.0",
    "mypy>=1.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["src/my_package"]
```

## Full pyproject.toml Example

```toml
[project]
name = "my-package"
version = "1.0.0"
description = "An awesome package"
readme = "README.md"
requires-python = ">=3.10"
license = {text = "MIT"}
authors = [{name = "Your Name", email = "you@example.com"}]
keywords = ["example", "package"]
classifiers = [
    "Development Status :: 4 - Beta",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]

dependencies = [
    "requests>=2.28.0,<3.0.0",
    "click>=8.0.0",
    "pydantic>=2.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "pytest-cov>=4.0",
    "ruff>=0.1.0",
    "mypy>=1.0",
]

[project.urls]
Homepage = "https://github.com/username/my-package"
Repository = "https://github.com/username/my-package"

[project.scripts]
my-cli = "my_package.cli:main"

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["src/my_package"]

# Ruff (linting + formatting)
[tool.ruff]
line-length = 100
target-version = "py310"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "W", "UP"]

# MyPy
[tool.mypy]
python_version = "3.10"
warn_return_any = true
disallow_untyped_defs = true

# Pytest
[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-v --cov=my_package"
```

## CLI with Click

```python
# src/my_package/cli.py
import click

@click.group()
@click.version_option()
def cli():
    """My CLI tool."""
    pass

@cli.command()
@click.argument("name")
@click.option("--greeting", default="Hello")
def greet(name: str, greeting: str):
    """Greet someone."""
    click.echo(f"{greeting}, {name}!")

def main():
    cli()

if __name__ == "__main__":
    main()
```

Register in pyproject.toml:
```toml
[project.scripts]
my-cli = "my_package.cli:main"
```

Test it:
```bash
uv run my-cli greet World
uv run my-cli greet --greeting="Hi" Alice
```

## Development Workflow

```bash
# Create and setup
uv init my-package
cd my-package
uv add --dev pytest ruff mypy

# Daily development
uv run pytest                    # Run tests
uv run ruff check .              # Lint
uv run ruff format .             # Format
uv run mypy src/                 # Type check

# Run any script
uv run python scripts/foo.py

# Run installed CLI
uv run my-cli --help
```

## Building and Publishing

```bash
# Build package
uv build

# Creates:
# dist/my_package-1.0.0.tar.gz
# dist/my_package-1.0.0-py3-none-any.whl

# Check distribution
uvx twine check dist/*

# Test on TestPyPI first
uvx twine upload --repository testpypi dist/*

# Install from TestPyPI to verify
uv pip install --index-url https://test.pypi.org/simple/ my-package

# Publish to PyPI
uvx twine upload dist/*
```

## Dynamic Versioning

```toml
[project]
name = "my-package"
dynamic = ["version"]

[tool.hatch.version]
path = "src/my_package/__init__.py"
```

In `__init__.py`:
```python
__version__ = "1.0.0"
```

## Including Data Files

```toml
[tool.hatch.build.targets.wheel]
packages = ["src/my_package"]

[tool.hatch.build.targets.wheel.shared-data]
"src/my_package/data" = "data"
```

Access data:
```python
from importlib.resources import files

data = files("my_package").joinpath("data/config.json").read_text()
```

## GitHub Actions

```yaml
# .github/workflows/publish.yml
name: Publish

on:
  release:
    types: [created]

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: astral-sh/setup-uv@v3
        with:
          version: "latest"

      - name: Build
        run: uv build

      - name: Publish
        env:
          TWINE_USERNAME: __token__
          TWINE_PASSWORD: ${{ secrets.PYPI_API_TOKEN }}
        run: uvx twine upload dist/*
```

## Common Patterns

### Editable Install (for development)
```bash
# uv handles this automatically in the project directory
# Just run your code with:
uv run python -c "from my_package import foo"
```

### Running Tests with Coverage
```bash
uv add --dev pytest-cov
uv run pytest --cov=my_package --cov-report=term-missing
```

### Type Stubs for Libraries
```bash
uv add --dev types-requests types-redis
```

## Checklist

- [ ] pyproject.toml complete with all metadata
- [ ] src/ layout used
- [ ] py.typed file for type hints
- [ ] README.md with usage examples
- [ ] LICENSE file
- [ ] Tests in tests/
- [ ] Dev dependencies for linting/testing
- [ ] CLI entry points if applicable
- [ ] Version number updated
- [ ] Tested on TestPyPI first

## Anti-Patterns

| Don't | Do |
|-------|-----|
| `pip install` | `uv add` |
| `python -m venv` | `uv init` (handles venv) |
| `pip install -e .` | `uv run` (auto editable) |
| `requirements.txt` | `pyproject.toml` dependencies |
| `setup.py` | `pyproject.toml` with hatchling |
| `pip freeze > requirements.txt` | `uv lock` creates `uv.lock` |

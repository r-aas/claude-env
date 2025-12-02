---
name: tdd-orchestrator
description: Master TDD orchestrator for red-green-refactor discipline with practical workflows. Use when implementing features test-first, debugging test failures, or establishing TDD practices. Covers pytest, Jest, and modern testing patterns.
---

# TDD Orchestrator

Test-Driven Development workflows with practical examples. Red → Green → Refactor.

## Quick Start

```bash
# Python (pytest)
uv add --dev pytest pytest-cov
uv run pytest --cov=src -v

# JavaScript/TypeScript (Jest)
npm install --save-dev jest @types/jest ts-jest
npx jest --coverage
```

## The Red-Green-Refactor Cycle

```
1. RED: Write a failing test for the next piece of functionality
2. GREEN: Write minimal code to make the test pass
3. REFACTOR: Clean up code while keeping tests green
4. REPEAT
```

**Key Rules:**
- Never write production code without a failing test
- Write the simplest code to pass the test
- Refactor only when tests are green
- One logical assertion per test

## Python TDD Workflow (pytest)

### Example: Building a User Service

#### Step 1: RED - Write Failing Test

```python
# tests/test_user_service.py
import pytest
from src.user_service import UserService, UserNotFoundError

class TestUserService:
    def test_create_user_returns_user_with_id(self):
        service = UserService()
        user = service.create_user(email="test@example.com", name="Test")

        assert user.id is not None
        assert user.email == "test@example.com"
        assert user.name == "Test"
```

Run: `uv run pytest tests/test_user_service.py -v`
Expected: ImportError (module doesn't exist yet)

#### Step 2: GREEN - Minimal Implementation

```python
# src/user_service.py
from dataclasses import dataclass
import uuid

@dataclass
class User:
    id: str
    email: str
    name: str

class UserNotFoundError(Exception):
    pass

class UserService:
    def create_user(self, email: str, name: str) -> User:
        return User(id=str(uuid.uuid4()), email=email, name=name)
```

Run: `uv run pytest tests/test_user_service.py -v`
Expected: PASSED

#### Step 3: Continue with Next Test

```python
# Add to tests/test_user_service.py
def test_get_user_returns_created_user(self):
    service = UserService()
    created = service.create_user(email="test@example.com", name="Test")

    retrieved = service.get_user(created.id)

    assert retrieved.id == created.id
    assert retrieved.email == created.email

def test_get_user_raises_when_not_found(self):
    service = UserService()

    with pytest.raises(UserNotFoundError):
        service.get_user("nonexistent-id")
```

#### Step 4: GREEN - Add Storage

```python
# src/user_service.py
class UserService:
    def __init__(self):
        self._users: dict[str, User] = {}

    def create_user(self, email: str, name: str) -> User:
        user = User(id=str(uuid.uuid4()), email=email, name=name)
        self._users[user.id] = user
        return user

    def get_user(self, user_id: str) -> User:
        if user_id not in self._users:
            raise UserNotFoundError(f"User {user_id} not found")
        return self._users[user_id]
```

## JavaScript TDD Workflow (Jest)

### Example: Building a Calculator

#### Step 1: RED

```typescript
// calculator.test.ts
import { Calculator } from './calculator';

describe('Calculator', () => {
  let calc: Calculator;

  beforeEach(() => {
    calc = new Calculator();
  });

  test('adds two numbers', () => {
    expect(calc.add(2, 3)).toBe(5);
  });

  test('subtracts two numbers', () => {
    expect(calc.subtract(5, 3)).toBe(2);
  });
});
```

#### Step 2: GREEN

```typescript
// calculator.ts
export class Calculator {
  add(a: number, b: number): number {
    return a + b;
  }

  subtract(a: number, b: number): number {
    return a - b;
  }
}
```

## Test Patterns

### Arrange-Act-Assert (AAA)

```python
def test_user_can_be_deactivated(self):
    # Arrange
    service = UserService()
    user = service.create_user(email="test@example.com", name="Test")

    # Act
    service.deactivate_user(user.id)

    # Assert
    updated = service.get_user(user.id)
    assert updated.is_active is False
```

### Given-When-Then (BDD Style)

```python
def test_deactivated_user_cannot_login(self):
    # Given a deactivated user
    service = UserService()
    user = service.create_user(email="test@example.com", name="Test")
    service.deactivate_user(user.id)

    # When they try to login
    # Then it should fail
    with pytest.raises(UserDeactivatedError):
        service.login(user.email, "password")
```

### Fixtures for Common Setup

```python
# conftest.py
import pytest
from src.user_service import UserService

@pytest.fixture
def user_service():
    return UserService()

@pytest.fixture
def sample_user(user_service):
    return user_service.create_user(email="test@example.com", name="Test")

# tests/test_user_service.py
def test_can_update_user_name(user_service, sample_user):
    user_service.update_user(sample_user.id, name="Updated")

    updated = user_service.get_user(sample_user.id)
    assert updated.name == "Updated"
```

### Parameterized Tests

```python
import pytest

@pytest.mark.parametrize("email,valid", [
    ("valid@example.com", True),
    ("invalid", False),
    ("no-domain@", False),
    ("@no-local.com", False),
])
def test_email_validation(email, valid):
    assert validate_email(email) == valid
```

## TDD Anti-Patterns to Avoid

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Test After | No design pressure | Write test FIRST |
| Multiple assertions | Hard to debug | One logical assertion |
| Testing implementation | Brittle tests | Test behavior |
| Slow tests | Breaks flow | Mock externals |
| Flaky tests | False failures | Fix or delete |
| No refactoring | Tech debt | Refactor in green |

## Testing Checklist

Before marking test complete:
- [ ] Test name describes behavior
- [ ] Test follows AAA/GWT pattern
- [ ] One logical assertion per test
- [ ] Test runs in isolation
- [ ] Test is deterministic (no flakiness)
- [ ] Edge cases covered

## Quick Commands

```bash
# Python
uv run pytest -v                      # Run all tests
uv run pytest -v -k "test_create"     # Run matching tests
uv run pytest --cov=src --cov-report=term-missing  # Coverage
uv run pytest -x                      # Stop on first failure
uv run pytest --lf                    # Run last failed

# JavaScript/TypeScript
npx jest --watch                      # Watch mode
npx jest --coverage                   # Coverage
npx jest -t "adds"                    # Run matching tests
npx jest --bail                       # Stop on first failure
```

## Integration with CI

```yaml
# .github/workflows/test.yml
name: Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v3
      - run: uv run pytest --cov=src --cov-report=xml
      - uses: codecov/codecov-action@v3
```

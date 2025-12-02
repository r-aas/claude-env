---
name: taskfile-patterns
description: Build automation with Taskfile.yml (go-task). Use when creating project automation, replacing Makefiles, orchestrating builds/deploys, or managing developer workflows. Covers syntax, variables, includes, dependencies, and common patterns.
---

# Taskfile Patterns

Modern task runner replacing Make. Simpler syntax, better cross-platform support, YAML-based.

## Quick Start

```bash
# Install (macOS)
brew install go-task

# Create Taskfile.yml
task --init

# Run default task
task

# List available tasks
task --list

# Run specific task
task build
```

## Basic Structure

```yaml
version: '3'

vars:
  NAME: myproject
  VERSION: 1.0.0

env:
  PATH:
    sh: echo "/opt/homebrew/bin:$PATH"

tasks:
  default:
    desc: Show available tasks
    cmds:
      - task --list

  build:
    desc: Build the project
    cmds:
      - echo "Building {{.NAME}} v{{.VERSION}}"
```

## Variables

### Static Variables

```yaml
vars:
  PROJECT: myapp
  ENV: development
```

### Dynamic Variables (shell)

```yaml
vars:
  GIT_COMMIT:
    sh: git rev-parse --short HEAD
  TIMESTAMP:
    sh: date +%Y%m%d-%H%M%S
  HOST_IP:
    sh: ifconfig en0 | grep "inet " | awk '{print $2}'
```

### Task-Level Variables

```yaml
tasks:
  deploy:
    vars:
      TARGET: production
    cmds:
      - echo "Deploying to {{.TARGET}}"
```

### CLI Variables

```yaml
tasks:
  greet:
    vars:
      NAME: '{{.NAME | default "World"}}'
    cmds:
      - echo "Hello, {{.NAME}}!"
```

Usage: `task greet NAME=Alice`

## Environment Variables

### Global Env

```yaml
env:
  DOCKER_BUILDKIT: 1
  PATH:
    sh: echo "/opt/homebrew/bin:$PATH"
```

### Dotenv Files

```yaml
dotenv: ['.env', '.env.local']

tasks:
  show:
    cmds:
      - echo $DATABASE_URL
```

### Task-Level Env

```yaml
tasks:
  test:
    env:
      ENV: test
      DEBUG: true
    cmds:
      - pytest
```

## Task Dependencies

### Run Before

```yaml
tasks:
  build:
    deps: [clean, lint]
    cmds:
      - go build

  clean:
    cmds:
      - rm -rf dist/

  lint:
    cmds:
      - golangci-lint run
```

### Sequential Dependencies

```yaml
tasks:
  deploy:
    cmds:
      - task: build
      - task: push
      - task: apply
```

### Parallel Execution

```yaml
tasks:
  check:
    deps:
      - task: lint
      - task: test
      - task: typecheck
    # deps run in parallel by default
```

## Includes (Modular Taskfiles)

### Directory Structure

```
project/
├── Taskfile.yml          # Main file
└── tasks/
    ├── build.yml
    ├── deploy.yml
    ├── docker.yml
    └── test.yml
```

### Main Taskfile

```yaml
version: '3'

includes:
  build: ./tasks/build.yml
  deploy: ./tasks/deploy.yml
  docker: ./tasks/docker.yml
  test: ./tasks/test.yml

tasks:
  default:
    cmds:
      - task --list
```

### Included Taskfile (tasks/docker.yml)

```yaml
version: '3'

vars:
  REGISTRY: registry.localhost:5001
  IMAGE: myapp

tasks:
  build:
    desc: Build Docker image
    cmds:
      - docker build -t {{.REGISTRY}}/{{.IMAGE}}:latest .

  push:
    desc: Push to registry
    cmds:
      - docker push {{.REGISTRY}}/{{.IMAGE}}:latest
```

Usage: `task docker:build`, `task docker:push`

### Namespace Prefixes

```yaml
includes:
  b: ./tasks/build.yml      # task b:all
  d: ./tasks/deploy.yml     # task d:apply
  t: ./tasks/test.yml       # task t:unit
```

## Common Patterns

### Lifecycle Pattern

```yaml
tasks:
  up:
    desc: Start everything
    cmds:
      - task: build
      - task: deploy
      - task: wait

  down:
    desc: Stop everything
    cmds:
      - kubectl delete -k k8s/

  restart:
    desc: Restart services
    cmds:
      - task: down
      - task: up

  status:
    desc: Show status
    cmds:
      - kubectl get pods
```

### Build Pattern

```yaml
tasks:
  build:
    desc: Build all images
    cmds:
      - task: build:api
      - task: build:worker

  build:api:
    cmds:
      - docker build -t myapp-api services/api

  build:worker:
    cmds:
      - docker build -t myapp-worker services/worker
```

### Watch Pattern

```yaml
tasks:
  dev:
    desc: Development with hot reload
    cmds:
      - uv run uvicorn app:app --reload

  watch:test:
    desc: Run tests on file change
    watch: true
    sources:
      - 'src/**/*.py'
      - 'tests/**/*.py'
    cmds:
      - uv run pytest
```

### Idempotent Pattern

```yaml
tasks:
  setup:db:
    desc: Create database if not exists
    status:
      - psql -lqt | cut -d \| -f 1 | grep -qw mydb
    cmds:
      - createdb mydb
```

### Interactive Commands

```yaml
tasks:
  shell:
    desc: Open shell in container
    interactive: true
    cmds:
      - kubectl exec -it deploy/myapp -- /bin/sh
```

## Gotchas & Solutions

### PATH Issues (macOS)

```yaml
# Problem: Commands not found
# Solution: Set PATH globally
env:
  PATH:
    sh: echo "/opt/homebrew/bin:/usr/local/bin:$PATH"
```

### Quote Handling

```yaml
tasks:
  # Problem: Quotes get mangled
  bad:
    cmds:
      - echo "Hello {{.NAME}}"  # May fail

  # Solution: Use cmd block
  good:
    cmds:
      - cmd: echo "Hello {{.NAME}}"
```

### Complex Commands

```yaml
tasks:
  # For pipes, redirects, complex shell
  complex:
    cmds:
      - cmd: |
          kubectl get pods -o json | \
            jq '.items[] | .metadata.name' | \
            head -5
        silent: true
```

### Passing Arguments

```yaml
tasks:
  # Using CLI_ARGS (catch-all)
  run:
    desc: "Usage: task run -- arg1 arg2"
    cmds:
      - python script.py {{.CLI_ARGS}}

  # Using named variable
  kubectl:
    desc: "Usage: task kubectl CMD='get pods'"
    vars:
      CMD: '{{.CMD | default "get pods"}}'
    cmds:
      - kubectl {{.CMD}} -n homelab
```

### Silent Mode

```yaml
tasks:
  quiet:
    silent: true  # Suppress command echo
    cmds:
      - echo "Only output shown"

  verbose:
    cmds:
      - cmd: echo "Command and output shown"
```

## Integration Examples

### With Docker

```yaml
vars:
  REGISTRY: registry.localhost:5001

tasks:
  docker:build:
    cmds:
      - docker build -t {{.REGISTRY}}/{{.IMAGE}}:{{.TAG}} .

  docker:push:
    cmds:
      - docker push {{.REGISTRY}}/{{.IMAGE}}:{{.TAG}}
```

### With Kubernetes

```yaml
tasks:
  k:apply:
    cmds:
      - kubectl apply -k k8s/base

  k:logs:
    vars:
      APP: '{{.APP | default "api"}}'
    cmds:
      - kubectl logs -f deploy/{{.APP}} -n homelab

  k:rollout:
    cmds:
      - kubectl rollout restart deploy/{{.APP}} -n homelab
      - kubectl rollout status deploy/{{.APP}} -n homelab
```

### With uv (Python)

```yaml
tasks:
  py:run:
    cmds:
      - uv run python {{.CLI_ARGS}}

  py:test:
    cmds:
      - uv run pytest -v

  py:lint:
    cmds:
      - uv run ruff check .
      - uv run ruff format --check .
```

### With Claude Code

```yaml
tasks:
  claude:
    desc: "Run Claude Code headless"
    vars:
      PROMPT: '{{.PROMPT | default "What can you help with?"}}'
    cmds:
      - cmd: |
          export PATH=/opt/homebrew/bin:$PATH
          npx @anthropic-ai/claude-code -p "{{.PROMPT}}"
```

## Best Practices

1. **Use includes** - Split large Taskfiles by domain
2. **Short prefixes** - `b:`, `d:`, `t:` for quick typing
3. **Add descriptions** - `desc:` for `task --list`
4. **Idempotent tasks** - Use `status:` to skip if done
5. **Silent where needed** - Reduce noise
6. **Set PATH globally** - Avoid "command not found"
7. **Use vars block** - Not CLI_ARGS for named params
8. **Document usage** - In desc or comments

## Quick Reference

```yaml
version: '3'

# Global variables
vars:
  NAME: value
  DYNAMIC:
    sh: command

# Global environment
env:
  KEY: value
dotenv: ['.env']

# Modular includes
includes:
  prefix: ./path/to/taskfile.yml

# Task definition
tasks:
  name:
    desc: Description for --list
    deps: [other, tasks]        # Run first (parallel)
    vars:
      LOCAL: value              # Task-scoped vars
    env:
      KEY: value                # Task-scoped env
    dir: ./subdir               # Working directory
    silent: true                # No command echo
    interactive: true           # For TTY
    sources:                    # For watch mode
      - 'src/**/*.py'
    status:                     # Skip if true
      - test -f output.txt
    cmds:
      - command {{.VAR}}
      - task: other-task
      - cmd: |
          multiline
          command
```

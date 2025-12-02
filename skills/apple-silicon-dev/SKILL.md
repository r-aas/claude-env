---
name: apple-silicon-dev
description: Development gotchas and patterns for Apple Silicon (M1/M2/M3/M4) Macs. Use when encountering ARM64 compatibility issues, Docker/container problems on Mac, Homebrew path issues, GPU/Metal considerations, or any macOS-specific development challenges. Covers Ollama, k3d, Keycloak, and common tool paths.
---

# Apple Silicon Development

Patterns and gotchas for development on Apple Silicon (ARM64) Macs.

## Quick Reference: Common Issues

| Problem | Cause | Fix |
|---------|-------|-----|
| Command not found | Homebrew path | Add `/opt/homebrew/bin` to PATH |
| Keycloak crashes (SIGILL) | JDK 21+ on ARM64 | Use `keycloak:24.0` (JDK 17) |
| Ollama slow in Docker | No GPU passthrough | Run Ollama natively on host |
| `host.docker.internal` fails | k3d networking | Use actual host IP |
| Python package fails | No ARM64 wheel | Use `uv` or build from source |
| Container image not found | AMD64 only | Check for ARM64/multi-arch image |

## Tool Paths

```bash
# Homebrew (Apple Silicon)
/opt/homebrew/bin/brew
/opt/homebrew/bin/node
/opt/homebrew/bin/npx
/opt/homebrew/bin/kubectl
/opt/homebrew/bin/docker
/opt/homebrew/bin/k3d
/opt/homebrew/bin/helm
/opt/homebrew/bin/jq

# Python (uv)
~/.local/bin/uv
~/.local/bin/uvx

# Ensure PATH in scripts
export PATH="/opt/homebrew/bin:$PATH"
```

## Homebrew PATH Issues

### In Shell Scripts
```bash
#!/bin/bash
export PATH="/opt/homebrew/bin:$PATH"
# Now commands work
```

### In Taskfile
```yaml
# Global env
env:
  PATH:
    sh: echo "/opt/homebrew/bin:$PATH"

# Or inline in command
cmds:
  - cmd: PATH=/opt/homebrew/bin:$PATH kubectl get pods
```

### In Makefiles
```makefile
SHELL := /bin/bash
export PATH := /opt/homebrew/bin:$(PATH)
```

## Docker on Apple Silicon

### No GPU Passthrough
Docker Desktop on Mac does NOT support GPU passthrough to containers.

**Impact:** ML workloads, Ollama, etc. must run natively on host.

**Pattern:**
```
Host (Metal GPU) → localhost:port
     ↑
Container → http://host.docker.internal:port  # or host IP
```

### Multi-Architecture Images

Check if image supports ARM64:
```bash
docker manifest inspect <image> | jq '.manifests[].platform'
```

Build multi-arch:
```bash
docker buildx build --platform linux/amd64,linux/arm64 -t myimage .
```

### x86 Emulation (Rosetta)

Force AMD64 image (slower, uses Rosetta):
```yaml
# docker-compose.yml
services:
  myservice:
    platform: linux/amd64
    image: some-amd64-only-image
```

## k3d / Kubernetes

### Host Access from Containers

`host.docker.internal` doesn't always work in k3d. Use actual host IP:

```bash
# Get host IP
ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'
# Example: 10.0.0.158

# In k8s manifest
env:
- name: OLLAMA_HOST
  value: "http://10.0.0.158:11434"
```

### PVC Mount Gotcha

Mounting PVC at application root can overwrite source files:

```yaml
# BAD - overwrites /app contents
volumeMounts:
- name: data
  mountPath: /app

# GOOD - mount subdirectory only
volumeMounts:
- name: data
  mountPath: /app/data
```

### Local Registry

k3d uses `registry.localhost:5001`:
```bash
# Push image
docker tag myimage registry.localhost:5001/myimage:latest
docker push registry.localhost:5001/myimage:latest

# Verify
curl http://registry.localhost:5001/v2/_catalog
```

## Ollama on Apple Silicon

### Setup
```bash
# Install (runs natively, gets Metal GPU)
brew install ollama

# Start
open -a Ollama
# or
ollama serve

# Verify GPU usage
ollama ps  # Should show "100% GPU"
```

### From Containers
```bash
# Get host IP
HOST_IP=$(ifconfig en0 | grep "inet " | awk '{print $2}')

# Test from container
docker run --rm curlimages/curl curl http://$HOST_IP:11434/api/tags
```

### Python Client Gotcha
```python
import ollama

# Response is object, not dict
response = ollama.chat(model="qwen2.5:7b", messages=[...])

# Use model_dump() or getattr()
data = response.model_dump()  # If Pydantic model
# or
content = response.message.content
```

## Keycloak on ARM64

### JDK 21+ Crash (SIGILL)
Keycloak with JDK 21+ crashes with SIGILL on virtualized ARM64 (Docker).

**Fix:** Use Keycloak 24.x which uses JDK 17:
```yaml
image: quay.io/keycloak/keycloak:24.0
```

### Environment Variables
Modern Keycloak uses `KC_*` prefix (Quarkus), not old JBoss style:
```yaml
env:
- name: KC_DB
  value: postgres
- name: KC_HOSTNAME
  value: keycloak.example.com
# NOT: KEYCLOAK_USER, DB_ADDR, etc.
```

## Python on Apple Silicon

### Use uv (not pip)
```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Create project
uv init myproject
cd myproject
uv add fastapi uvicorn

# Run
uv run python main.py
```

### Packages with Native Extensions
Some packages don't have ARM64 wheels. uv usually handles this, but if issues:
```bash
# Force build from source
uv pip install --no-binary :all: problematic-package

# Or use Rosetta Python
arch -x86_64 /usr/bin/python3 -m pip install package
```

### Common Problem Packages
| Package | Issue | Fix |
|---------|-------|-----|
| `grpcio` | Old versions lack ARM64 | Use latest version |
| `tensorflow` | Use tensorflow-macos | `pip install tensorflow-macos` |
| `torch` | MPS backend | `pip install torch` (auto-detects) |
| `scipy` | Build issues | `brew install openblas` first |

## Node.js on Apple Silicon

```bash
# Homebrew node (ARM64 native)
/opt/homebrew/bin/node
/opt/homebrew/bin/npm
/opt/homebrew/bin/npx

# For packages with native modules
npm rebuild  # After switching architectures
```

## Performance Tips

### Metal GPU
- Ollama, PyTorch, TensorFlow can use Metal GPU automatically
- No config needed - just run natively (not in Docker)
- Check: `system_profiler SPDisplaysDataType`

### Memory
- Unified memory is shared between CPU and GPU
- M4 Max with 128GB: ~90GB usable for ML after system
- Large models (70B+) work well with unified memory

### Rosetta Overhead
- ~20% slower for emulated x86
- Prefer ARM64 native when possible
- Use `arch` command to check: `arch` → `arm64`

## Taskfile Template for Mac

```yaml
version: '3'

env:
  PATH:
    sh: echo "/opt/homebrew/bin:/usr/local/bin:$PATH"

tasks:
  default:
    cmds:
      - task --list

  # Example with proper paths
  build:
    cmds:
      - /opt/homebrew/bin/docker build -t myapp .

  # Or use env
  run:
    cmds:
      - python main.py
```

## Debugging Tips

### Check Architecture
```bash
# Current shell
arch  # arm64 or i386

# File type
file /path/to/binary

# Running processes
ps aux | grep myprocess
# Then check with: file /path/to/process
```

### Docker Issues
```bash
# Check Docker platform
docker info | grep -i platform

# Inspect image architecture
docker inspect myimage | jq '.[0].Architecture'

# Run with explicit platform
docker run --platform linux/arm64 myimage
```

### Homebrew Issues
```bash
# Verify ARM Homebrew
which brew  # Should be /opt/homebrew/bin/brew
brew config | grep HOMEBREW_PREFIX  # Should be /opt/homebrew

# If x86 Homebrew installed too
/opt/homebrew/bin/brew ...  # ARM
/usr/local/bin/brew ...     # x86 (Rosetta)
```

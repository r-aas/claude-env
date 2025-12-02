---
name: mcp-development
description: Build MCP (Model Context Protocol) servers using FastMCP/Python or TypeScript SDK. Use when creating MCP servers, implementing tools/resources/prompts, debugging MCP protocol issues, or integrating with agent-gateway. Covers server structure, tool patterns, testing, deployment, and registration.
---

# MCP Server Development

Build production-ready MCP servers. Supports Python (FastMCP) and TypeScript (MCP SDK).

## Quick Start

### Python (FastMCP) - Recommended for R's stack

```bash
# Create new MCP server
mkdir -p services/mcp-{name}
cd services/mcp-{name}

# Initialize with uv
uv init
uv add fastmcp uvicorn starlette httpx
```

### TypeScript

```bash
mkdir mcp-{name} && cd mcp-{name}
npm init -y
npm install @modelcontextprotocol/sdk zod
```

## Server Architecture

### Standard Structure (Python)

```
services/mcp-{name}/
├── server.py          # FastMCP + Starlette endpoints
├── pyproject.toml     # uv dependencies
├── Dockerfile         # Python 3.12-slim base
└── tests/
    └── test_server.py
```

### Required Endpoints

| Endpoint | Method | Purpose | Required |
|----------|--------|---------|----------|
| `/health` | GET | k8s liveness/readiness | Yes |
| `/tools` | GET | List available tools (discovery) | Yes |
| `/invoke` | POST | Direct HTTP tool invocation | Yes |
| `/mcp` | POST | Full MCP JSON-RPC protocol | Optional |

## Python Server Template

```python
"""MCP Server: {name}"""
from fastmcp import FastMCP
from starlette.applications import Starlette
from starlette.responses import JSONResponse
from starlette.routing import Route
import uvicorn

mcp = FastMCP("{name}")


# === Tools ===

@mcp.tool()
async def my_tool(param: str) -> str:
    """Tool description for discovery.

    Args:
        param: Description of parameter

    Returns:
        Description of return value
    """
    return f"Result: {param}"


@mcp.tool()
async def another_tool(data: dict) -> dict:
    """Another tool with structured I/O."""
    return {"processed": data, "status": "success"}


# === HTTP Endpoints ===

async def health(request):
    """Health check for k8s probes."""
    return JSONResponse({
        "status": "healthy",
        "service": "{name}",
        "tools": len(mcp._tool_manager._tools)
    })


async def list_tools(request):
    """List available tools for discovery."""
    tools = []
    for name, tool in mcp._tool_manager._tools.items():
        tools.append({
            "name": name,
            "description": tool.description or "",
            "parameters": tool.parameters if hasattr(tool, 'parameters') else {}
        })
    return JSONResponse({"tools": tools})


async def invoke(request):
    """Direct tool invocation via HTTP."""
    body = await request.json()
    tool_name = body.get("name")
    arguments = body.get("arguments", {})

    if tool_name not in mcp._tool_manager._tools:
        return JSONResponse({"error": f"Unknown tool: {tool_name}"}, status_code=404)

    try:
        tool = mcp._tool_manager._tools[tool_name]
        result = await tool.fn(**arguments)
        return JSONResponse({"result": result})
    except Exception as e:
        return JSONResponse({"error": str(e)}, status_code=500)


app = Starlette(routes=[
    Route("/health", health, methods=["GET"]),
    Route("/tools", list_tools, methods=["GET"]),
    Route("/invoke", invoke, methods=["POST"]),
])

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

## TypeScript Server Template

```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new Server({
  name: "my-server",
  version: "1.0.0",
}, {
  capabilities: { tools: {} }
});

// Register tool
server.registerTool({
  name: "my_tool",
  description: "Tool description",
  inputSchema: z.object({
    param: z.string().describe("Parameter description")
  }),
  outputSchema: z.object({
    result: z.string()
  }),
  annotations: {
    readOnlyHint: true,
    idempotentHint: true
  }
}, async (args) => {
  return { result: `Processed: ${args.param}` };
});

// Start server
const transport = new StdioServerTransport();
await server.connect(transport);
```

## Tool Design Rules

1. **Async by default** - All tools should be `async def`
2. **Type hints required** - Parameters and return types must be typed
3. **Docstrings required** - First line is tool description for discovery
4. **Return JSON-serializable** - Only dicts, lists, strings, numbers, bools
5. **Handle errors gracefully** - Never raise, return error in response
6. **Timeout external calls** - Always set timeout on httpx/aiohttp requests
7. **Stateless preferred** - Tools should be idempotent when possible

## Tool Patterns

### External API Call

```python
@mcp.tool()
async def fetch_data(url: str) -> dict:
    """Fetch data from external URL."""
    import httpx
    async with httpx.AsyncClient() as client:
        resp = await client.get(url, timeout=30.0)
        resp.raise_for_status()
        return resp.json()
```

### With Error Handling

```python
@mcp.tool()
async def safe_operation(input: str) -> dict:
    """Operation with proper error handling."""
    try:
        result = await do_something(input)
        return {"success": True, "result": result}
    except ValueError as e:
        return {"success": False, "error": str(e)}
    except Exception as e:
        logger.exception("Operation failed")
        return {"success": False, "error": "Internal error"}
```

## Testing

### Local Testing

```bash
# Start server
cd services/mcp-{name}
uv run server.py

# Test endpoints
curl http://localhost:8000/health
curl http://localhost:8000/tools
curl -X POST http://localhost:8000/invoke \
  -H "Content-Type: application/json" \
  -d '{"name": "my_tool", "arguments": {"param": "test"}}'
```

### Unit Tests

```python
import pytest
from httpx import AsyncClient, ASGITransport
from server import app

@pytest.fixture
async def client():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as c:
        yield c

@pytest.mark.asyncio
async def test_health(client):
    resp = await client.get("/health")
    assert resp.status_code == 200
    assert resp.json()["status"] == "healthy"

@pytest.mark.asyncio
async def test_invoke_tool(client):
    resp = await client.post("/invoke", json={
        "name": "my_tool",
        "arguments": {"param": "test"}
    })
    assert resp.status_code == 200
    assert "result" in resp.json()
```

## Deployment

### Build and Push

```bash
# Build image
docker build -t registry.localhost:5001/mcp-gateway-registry/mcp-{name}:latest services/mcp-{name}

# Push to local registry
docker push registry.localhost:5001/mcp-gateway-registry/mcp-{name}:latest
```

### Kubernetes Manifest

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mcp-{name}
  namespace: homelab
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mcp-{name}
  template:
    spec:
      containers:
      - name: mcp-{name}
        image: registry.localhost:5001/mcp-gateway-registry/mcp-{name}:latest
        ports:
        - containerPort: 8000
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
---
apiVersion: v1
kind: Service
metadata:
  name: mcp-{name}
  namespace: homelab
spec:
  selector:
    app: mcp-{name}
  ports:
  - port: 8000
```

## URL Resolution

Agent-gateway resolves MCP server URLs:
1. **Cache hit** - Previous successful lookup
2. **Registry lookup** - Query MCP registry for `proxy_pass_url`
3. **Convention fallback** - `/foo` → `http://mcp-foo:8000`

**Naming convention:** `/echo` → `mcp-echo:8000`

## Best Practices

1. **One domain per server** - Keep servers focused (weather, time, files)
2. **Document all tools** - Docstrings become discovery metadata
3. **Test locally first** - Before k8s deployment
4. **Health checks always** - Required for k8s readiness/liveness
5. **Graceful errors** - Return error in response, never raise
6. **Async everything** - Non-blocking I/O for performance

## Debugging

| Issue | Cause | Fix |
|-------|-------|-----|
| Tool not found | Typo in tool name | Check `/tools` endpoint |
| 500 on invoke | Unhandled exception | Add try/except, check logs |
| Timeout | External API slow | Add timeout parameter |
| JSON error | Non-serializable return | Return only primitives/dicts/lists |
| Import error | Missing dependency | Add to pyproject.toml, run `uv sync` |

## Resources

- **MCP Specification**: https://modelcontextprotocol.io/
- **FastMCP**: https://github.com/jlowin/fastmcp
- **TypeScript SDK**: https://github.com/modelcontextprotocol/typescript-sdk
- **Python SDK**: https://github.com/modelcontextprotocol/python-sdk

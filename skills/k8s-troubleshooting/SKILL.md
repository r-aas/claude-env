---
name: k8s-troubleshooting
description: Systematic Kubernetes troubleshooting for pods, services, ingress, networking, storage, and resource issues. Use when pods won't start, services are unreachable, ingress returns errors, containers crash, images won't pull, DNS fails, or any k8s resource isn't behaving as expected. Covers CrashLoopBackOff, ImagePullBackOff, pending pods, 502/503/504 errors, and more.
---

# Kubernetes Troubleshooting

Systematic approach to debugging Kubernetes issues. Follow the diagnostic tree, gather evidence, then fix.

## Quick Reference Commands

```bash
# Status overview
kubectl get pods -n homelab -o wide
kubectl get events -n homelab --sort-by='.lastTimestamp' | tail -20
kubectl top pods -n homelab

# Pod details
kubectl describe pod <pod> -n homelab
kubectl logs <pod> -n homelab --tail=100
kubectl logs <pod> -n homelab --previous  # crashed container logs

# Service/Networking
kubectl get svc,endpoints -n homelab
kubectl get ingress -n homelab

# Quick exec for debugging
kubectl exec -it <pod> -n homelab -- /bin/sh
kubectl run debug --rm -it --image=busybox -- /bin/sh
```

## Diagnostic Decision Tree

```
Problem identified
│
├─ Pod not running?
│  ├─ Status: Pending → Check resources, node selector, PVC
│  ├─ Status: ImagePullBackOff → Check image name, registry, secrets
│  ├─ Status: CrashLoopBackOff → Check logs, probe config, resources
│  ├─ Status: Init:Error → Check init container logs
│  └─ Status: Terminating → Check finalizers, force delete if stuck
│
├─ Pod running but not working?
│  ├─ Check application logs
│  ├─ Check readiness/liveness probes
│  ├─ Check environment variables
│  └─ Exec into pod and test
│
├─ Service not reachable?
│  ├─ Check endpoints exist
│  ├─ Check selector matches pod labels
│  ├─ Check port configuration
│  └─ Test from within cluster
│
├─ Ingress returning errors?
│  ├─ 404 → Check path, service name
│  ├─ 502/503 → Backend pod not ready
│  ├─ 504 → Timeout, check pod health
│  └─ SSL error → Check certificate, TLS secret
│
└─ Storage issues?
   ├─ PVC pending → Check storage class, provisioner
   ├─ Mount failed → Check PV exists, access modes
   └─ Permission denied → Check securityContext, fsGroup
```

## Pod Issues

### CrashLoopBackOff

**Symptoms:** Pod repeatedly crashes and restarts

**Diagnosis:**
```bash
# Check current logs
kubectl logs <pod> -n homelab

# Check previous crash logs (critical!)
kubectl logs <pod> -n homelab --previous

# Check events
kubectl describe pod <pod> -n homelab | grep -A 20 Events
```

**Common causes:**
| Cause | Evidence | Fix |
|-------|----------|-----|
| App error | Stack trace in logs | Fix application code |
| Missing env var | "undefined", KeyError in logs | Add env var to deployment |
| Bad config | Parse errors in logs | Fix configmap/secret |
| OOMKilled | `OOMKilled` in describe | Increase memory limits |
| Probe failure | Probe failed message | Fix probe or increase timeout |
| Wrong command | Command not found | Fix container command/args |

### ImagePullBackOff

**Symptoms:** Image can't be pulled

**Diagnosis:**
```bash
kubectl describe pod <pod> -n homelab | grep -A 5 "Events"
# Look for: "Failed to pull image"
```

**Common causes:**
| Cause | Evidence | Fix |
|-------|----------|-----|
| Wrong image name | "not found" | Check image:tag exactly |
| Private registry | "unauthorized" | Add imagePullSecrets |
| Local registry | "connection refused" | Check registry.localhost:5001 |
| Tag doesn't exist | "manifest unknown" | Verify tag exists |

**For local registry (k3d):**
```bash
# Verify image exists
docker images | grep <image>

# Push to local registry
docker tag <image> registry.localhost:5001/...:latest
docker push registry.localhost:5001/...:latest

# Verify in registry
curl -s http://registry.localhost:5001/v2/_catalog
```

### Pending Pod

**Symptoms:** Pod stuck in Pending state

**Diagnosis:**
```bash
kubectl describe pod <pod> -n homelab | grep -A 10 Events
```

**Common causes:**
| Cause | Evidence | Fix |
|-------|----------|-----|
| No resources | "Insufficient cpu/memory" | Scale cluster or reduce requests |
| Node selector | "node selector" | Check nodeSelector matches |
| PVC not bound | "persistentvolumeclaim not found" | Create/fix PVC |
| Taints | "node had taint" | Add toleration or remove taint |

### Init Container Failure

**Symptoms:** Pod stuck at Init:0/1 or Init:Error

**Diagnosis:**
```bash
# Check init container logs specifically
kubectl logs <pod> -n homelab -c <init-container-name>

# List init containers
kubectl get pod <pod> -n homelab -o jsonpath='{.spec.initContainers[*].name}'
```

## Service Issues

### Service Has No Endpoints

**Symptoms:** Service exists but can't reach pods

**Diagnosis:**
```bash
# Check endpoints
kubectl get endpoints <service> -n homelab

# Empty endpoints means selector doesn't match
# Compare selector to pod labels
kubectl get svc <service> -n homelab -o jsonpath='{.spec.selector}'
kubectl get pods -n homelab --show-labels
```

**Fix:** Ensure service selector matches pod labels exactly

### Service Port Mismatch

**Symptoms:** Connection refused or wrong response

**Check:**
```bash
# Service configuration
kubectl get svc <service> -n homelab -o yaml

# Verify:
# - port: external port (what you connect to)
# - targetPort: container port (what app listens on)
# - protocol: TCP/UDP match
```

### DNS Resolution Failure

**Symptoms:** "could not resolve host"

**Test:**
```bash
# From within cluster
kubectl run dns-test --rm -it --image=busybox -- nslookup <service>.homelab.svc.cluster.local

# Check CoreDNS
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl logs -n kube-system -l k8s-app=kube-dns
```

## Ingress Issues

### 404 Not Found

**Diagnosis:**
```bash
kubectl get ingress -n homelab -o yaml
# Check:
# - host matches request
# - path matches (exact vs prefix)
# - backend service name correct
# - backend service port correct
```

**Common fixes:**
- Path type: `Prefix` vs `Exact` vs `ImplementationSpecific`
- Missing trailing slash handling
- Service name typo

### 502 Bad Gateway

**Meaning:** Ingress reached backend but got error

**Diagnosis:**
```bash
# Check if backend pod is ready
kubectl get pods -n homelab -l app=<backend>

# Check pod readiness
kubectl describe pod <pod> -n homelab | grep -A 5 Conditions

# Test service directly (from inside cluster)
kubectl exec -it <any-pod> -n homelab -- curl http://<service>:port/health
```

**Common causes:**
- Pod not ready (readiness probe failing)
- Service port mismatch
- App not listening on expected port

### 503 Service Unavailable

**Meaning:** No healthy backends

**Check:**
- All backend pods crashed?
- Endpoints exist?
- Service selector correct?

### 504 Gateway Timeout

**Meaning:** Backend too slow

**Check:**
- Application performance
- Increase ingress timeout annotations
- Check resource constraints

### TLS/Certificate Issues

**Diagnosis:**
```bash
# Check certificate secret exists
kubectl get secret <tls-secret> -n homelab

# Check certificate details
kubectl get secret <tls-secret> -n homelab -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -text -noout

# Verify cert matches domain
```

## Storage Issues

### PVC Pending

**Diagnosis:**
```bash
kubectl describe pvc <pvc> -n homelab
# Look for: "waiting for first consumer"
# Or: "no persistent volumes available"
```

**For k3d local-path:**
```bash
# Check storage class exists
kubectl get storageclass

# Check provisioner is running
kubectl get pods -n kube-system | grep local-path
```

### Volume Mount Permission Denied

**Symptoms:** App can't write to mounted volume

**Fix:** Add securityContext to pod/container:
```yaml
securityContext:
  fsGroup: 1000
  runAsUser: 1000
```

## Networking Issues

### Pod-to-Pod Communication

**Test:**
```bash
# Get pod IPs
kubectl get pods -n homelab -o wide

# Test connectivity
kubectl exec -it <pod1> -n homelab -- ping <pod2-ip>
kubectl exec -it <pod1> -n homelab -- curl http://<pod2-ip>:port
```

### External Access (from host)

**For k3d/local:**
```bash
# Test ingress
curl -sk https://<service>.127-0-0-1.sslip.io/health

# Check Traefik is running
kubectl get pods -n kube-system | grep traefik

# Check Traefik logs
kubectl logs -n kube-system -l app.kubernetes.io/name=traefik
```

### Host-to-Cluster (Ollama pattern)

**For accessing host services from k3d:**
```bash
# Get host IP
ifconfig | grep "inet " | grep -v 127.0.0.1

# Use in deployment
env:
- name: OLLAMA_HOST
  value: "http://10.0.0.158:11434"  # NOT localhost!

# Verify from pod
kubectl exec -it <pod> -n homelab -- curl http://10.0.0.158:11434
```

## Resource Issues

### OOMKilled

**Symptoms:** Container killed, restarts

**Diagnosis:**
```bash
kubectl describe pod <pod> -n homelab | grep -i oom
kubectl describe pod <pod> -n homelab | grep -A 5 "Last State"
```

**Fix:** Increase memory limits:
```yaml
resources:
  limits:
    memory: "512Mi"  # Increase this
  requests:
    memory: "256Mi"
```

### CPU Throttling

**Diagnosis:**
```bash
kubectl top pods -n homelab
# Compare to limits
kubectl get pod <pod> -n homelab -o jsonpath='{.spec.containers[0].resources}'
```

## Quick Fixes Cheatsheet

| Problem | Quick Command |
|---------|--------------|
| Force delete stuck pod | `kubectl delete pod <pod> -n homelab --force --grace-period=0` |
| Restart deployment | `kubectl rollout restart deployment/<name> -n homelab` |
| Check all events | `kubectl get events -n homelab --sort-by='.lastTimestamp'` |
| Debug with temp pod | `kubectl run debug --rm -it --image=busybox -n homelab -- sh` |
| Port forward to test | `kubectl port-forward svc/<svc> 8080:80 -n homelab` |
| Watch pod status | `kubectl get pods -n homelab -w` |
| Exec as root | `kubectl exec -it <pod> -n homelab -- /bin/sh` (if allowed) |

## Homelab-Specific Gotchas

| Issue | Cause | Fix |
|-------|-------|-----|
| Registry image not found | Wrong path | Use `registry.localhost:5001/mcp-gateway-registry/<image>` |
| Ollama unreachable | Using localhost | Use host IP (10.0.0.x) not localhost |
| Ingress 404 | Wrong path | Check IngressRoute vs Ingress resource |
| PVC mount overwrites | Mounted at app root | Mount at subdirectory only |
| Pod can't resolve DNS | CoreDNS issue | Restart CoreDNS pods |
| Keycloak SIGILL | JDK 21 on ARM64 | Use keycloak:24.0 (JDK 17) |

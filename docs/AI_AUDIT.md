# AI artifact audit

Tool: ChatGPT. The assistant created and reviewed this project. Bashir must review it and run the deployment checks before claiming personal verification.

The files in `initial-draft/` are intentionally flawed teaching drafts generated during this session, not artifacts from an earlier student deployment. They preserve concrete before/after examples for the video. Do not run them.

| Check | Teaching draft problem | Final correction | Evidence still needed |
|---|---|---|---|
| Build stages | One stage retains source and build context | Separate `build` and `runtime`; only `dist/` crosses the boundary | Actual build output and image inspection |
| Layer caching | `COPY . .` invalidates install on any source change | Copy package metadata first, `npm ci`, then application files | Second build after changing only HTML |
| Least privilege | No USER declaration means default root | Official base creates node UID 1000; final `USER node`; pod forces UID 1000 | `kubectl exec ... -- id -u` and `ps` |
| Base image | Moving `node:latest` and full default image | Fixed `node:22.16.0-alpine3.22` tag in both stages | Pull/build; scan and update before real production use |
| Secrets | Broad copy could include local environment files | `.dockerignore` excludes `.env*`; no secrets committed | Review local files before push |
| Resource budget | No requests or limits | 100m CPU / 64Mi requested, 500m CPU / 128Mi limited per pod | `kubectl describe pod` |
| Health and readiness | No health checks | Docker HEALTHCHECK plus Kubernetes startup/liveness/readiness probes | Actual 200 responses and Ready pod status |
| Availability | One replica and no release policy | Two initial replicas; RollingUpdate maxUnavailable=0, maxSurge=1 | Scale, delete pod, update, rollback |
| Runtime restrictions | No hardening | No privilege escalation; read-only root; drop ALL capabilities; RuntimeDefault seccomp; no service-account token | Deployment inspection |

## Technical qualifications

- This application has zero third-party dependencies. `npm ci` verifies the lockfile, but there is no large dependency tree to prune. The multi-stage build excludes tests and documentation rather than a compiler toolchain. Do not exaggerate size savings: record the real image size.
- Fixed version tags can still be republished. Registry digests provide stronger byte-level reproducibility. No digest is invented here, and this tag is not a claim of a current vulnerability-free image.
- Kubernetes does not use Dockerfile HEALTHCHECK as its readiness/liveness policy; the manifest defines those probes explicitly.
- Readiness removes an unready pod from service endpoints. Liveness restarts a failing container. The ReplicaSet replaces a deleted pod. These are distinct mechanisms.
- `maxUnavailable: 0` supports availability but does not prove zero failed requests. A service tunnel, single-node cluster failure, capacity shortage, or routing propagation can still interrupt access.
- Local `imagePullPolicy: Never` is intentional: load the image into this Minikube profile before deploying. A real registry deployment should use a published digest and suitable pull policy.
- The application handles SIGTERM and drains before exit, within the pod's termination grace period. Hard pod deletion is a resilience simulation, not a node-failure test.

## Sources

- Docker multi-stage builds: https://docs.docker.com/build/building/multi-stage/
- Kubernetes Deployments: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
- Kubernetes probes: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
- Kubernetes security constraints: https://kubernetes.io/docs/concepts/security/linux-kernel-security-constraints/
- Minikube access: https://minikube.sigs.k8s.io/docs/handbook/accessing/
- Fixed base tag: https://hub.docker.com/layers/library/node/22.16.0-alpine3.22/

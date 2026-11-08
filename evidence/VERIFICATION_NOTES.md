# Verification notes

- Native tests: Node.js v24.22.1, 7 passed, 0 failed. See native-tests.txt.
- Runtime directory build: passed. See native-build.txt.
- `npm` printed an inherited environment configuration warning about http-proxy in this workspace. This is preserved in the logs and is not a clean container-build result.
- Kubernetes YAML: parsed with PyYAML; checked resource limits, probes, selectors, and service targetPort. This is not Kubernetes API validation.
- Browser: could not launch here. No browser pass is claimed.
- PowerShell scripts: prepared for Windows; no PowerShell runtime was available here to execute them.
- Docker/Kubernetes: unavailable here. All deployment and resilience evidence must be generated on the student's computer.
- Host tests use Node 24; the pinned container runtime is Node 22. Container tests execute again during the actual Docker build.

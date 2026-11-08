# QA checklist and evidence

A completed checklist must reflect actual results. Items below marked pending have not been performed in the assistant's environment. After running them, replace Pending with PASS/FAIL, include the timestamp, and link the real evidence. Do not invent results.

| Check | Current result | Evidence / action |
|---|---|---|
| Native application endpoints and behavior | PASS | `evidence/native-tests.txt`: 7 automated tests |
| Runtime-only directory build | PASS | `evidence/native-build.txt` |
| Local browser page and frontend behavior | Pending (browser unavailable) | `evidence/browser-check.json` if generated; host only |
| Container builds without warnings/errors | Pending | Record actual Docker build output |
| Tagged final image and lean size | Pending | `docker images` and actual byte size; do not claim an unmeasured reduction |
| Deployed process runs non-root | Pending | Pod `id -u`, `ps`, runtime UID |
| Containerized landing page HTTP 200 | Pending | Cluster URL and Network or curl evidence |
| Containerized /healthz HTTP 200 and payload | Pending | Cluster curl output |
| Runtime hostname / pod identity | Pending | Runtime JSON and browser |
| Two initial replicas ready | Pending | Initial `get pods` |
| Scale to three replicas | Pending | Three Ready pods |
| Failed/deleted pod replacement | Pending | Before/after pod UID and three Ready replacements |
| Rolling update to v2 | Pending | Rollout success and runtime version |
| Rollback to v1 | Pending | Rollout success and runtime version |
| Cluster browser status, headers, response times | Pending | DevTools Network screenshot |
| Cluster frontend console has no uncaught errors | Pending | DevTools Console screenshot |
| Screen and face visible for 5–7 minute video | Pending | Actual recording and YouTube access check |

## Automation

Run `scripts/qa.ps1` using the live Minikube service URL. It generates real cluster evidence only when executed successfully. Review every result, then update this checklist. Host endpoint tests and a local browser run do not replace container deployment evidence.

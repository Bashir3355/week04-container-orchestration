# AI disclosure and prompt log

AI tool: ChatGPT. The assistant generated the application, Dockerfile, manifests, documentation, teaching drafts, and test automation. The assistant audited the generated configuration and ran the Node endpoint tests in its workspace. The student has not yet supplied cluster evidence or a recording.

## Exact user prompt

> Complete this assignment?

Attachment: `Pasted text(20261108-025509).txt`. Its exact assignment text is preserved as `ASSIGNMENT.txt` beside this log. The attachment includes the sample DevOps prompt and the full rubric. This was an attached instruction, not a separately submitted historical prompt.

## Scope decisions made by the assistant

The user did not submit a separate follow-up implementation prompt. These were assistant choices during the same task, not fabricated user prompts:

- Choose a dependency-free Node.js application with a Kubernetes Minikube Deployment and NodePort Service.
- Preserve an explicitly labelled flawed teaching draft and audit its root user, moving image tag, broad COPY order, single stage, and missing pod controls.
- Correct the final artifacts and include PowerShell deployment and QA scripts.
- Record native application tests honestly. Leave Docker build, Kubernetes scaling, replacement, browser inspection, and video checks pending until actually executed.

## What the final AI output handled correctly

It includes application and runtime endpoints, multi-stage packaging, dependency metadata before source, a non-root runtime, two initial replicas, explicit resource requests/limits, separate readiness and liveness endpoints, and commands for scaling and rollback.

## Corrections to review in the video

Compare `initial-draft/Dockerfile.before` with the final Dockerfile. Explain the broad `COPY . .` caching issue and missing `USER`. Compare the draft manifest with `k8s/app.yaml` for probes and resource constraints. These corrections were made with AI assistance. Do not describe them as changes you manually made before reviewing them yourself.

If you submit additional prompts while troubleshooting, append their exact wording and the resulting changes here.

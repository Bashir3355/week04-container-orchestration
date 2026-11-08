# Publish my repository

1. Sign in to GitHub as Bashir3355.
2. Create an empty repository named `week04-container-orchestration`. Do not initialize it with another README.
3. Complete the real cluster checks, update `docs/QA_CHECKLIST.md`, and review evidence for sensitive data.
4. Open PowerShell in the project root and run:

```powershell
git init
git add .
git commit -m "Add containerized web app, Kubernetes deployment, AI audit and QA"
git branch -M main
git remote add origin https://github.com/Bashir3355/week04-container-orchestration.git
git push -u origin main
```

If this folder is already a Git repository, inspect `git status` and `git remote -v` before initializing or adding a remote. GitHub may prompt you to authenticate through your browser. Never paste a password or token into committed files.

The URL above is a proposed new repository destination, not a claim that it already exists. Copy the actual repository URL into `docs/SUBMISSION.md` only after publication succeeds.

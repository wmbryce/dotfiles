#!/usr/bin/env bash
# Make sure `gh` is authed before we try to clone private repos. Idempotent —
# if you're already logged in this is a no-op.
set -euo pipefail

if ! command -v gh &>/dev/null; then
  echo "!! gh not installed; skipping (run bootstrap to install it)" >&2
  exit 0
fi

if gh auth status &>/dev/null; then
  echo "==> gh: already authenticated"
else
  echo "==> gh: launching interactive login"
  echo "    pick: GitHub.com → HTTPS → Login with a web browser"
  gh auth login
fi

# Wire git so https clones use the gh-cached token (covers later `git clone`,
# `git pull`, `git push` against private repos without needing an ssh key).
gh auth setup-git

echo "==> gh: ready"

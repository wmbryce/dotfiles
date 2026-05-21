#!/usr/bin/env bash
# OS-detecting entry point. Delegates to bootstrap-macos.sh or bootstrap-linux.sh.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
  Darwin) exec bash "$HERE/bootstrap-macos.sh" "$@" ;;
  Linux)  exec bash "$HERE/bootstrap-linux.sh" "$@" ;;
  *)      echo "unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

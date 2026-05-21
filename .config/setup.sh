#!/usr/bin/env bash
# Legacy entrypoint. Real work lives in scripts/.
# For a fresh box, prefer: bash ~/dotfiles/.config/scripts/bootstrap.sh
set -euo pipefail
exec bash "$(dirname "$0")/scripts/link.sh"

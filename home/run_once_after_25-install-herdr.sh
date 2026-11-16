#!/bin/sh
# Install herdr with its official installer if it's missing. The
# installer checks the binary's SHA-256 against herdr's release
# manifest and puts it in ~/.local/bin; `herdr update` keeps it current
# afterwards.

set -eu

if command -v herdr >/dev/null 2>&1 || [ -x "$HOME/.local/bin/herdr" ]; then
	exit 0
fi

curl -fsSL https://herdr.dev/install.sh | sh

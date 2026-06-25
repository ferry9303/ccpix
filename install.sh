#!/usr/bin/env bash
# Install ccpix without Homebrew: symlink it into a directory on your PATH.
set -euo pipefail

src="$(cd "$(dirname "$0")" && pwd)/ccpix"
dest="${1:-$HOME/.local/bin}"

mkdir -p "$dest"
ln -sf "$src" "$dest/ccpix"
chmod +x "$src"

echo "Linked $dest/ccpix -> $src"
case ":$PATH:" in
  *":$dest:"*) ;;
  *) echo "Note: $dest is not on your PATH. Add it, e.g.:"
     echo "  echo 'export PATH=\"$dest:\$PATH\"' >> ~/.zshrc" ;;
esac
command -v chafa >/dev/null 2>&1 || \
  echo "Tip: 'brew install chafa' for inline images outside iTerm2."

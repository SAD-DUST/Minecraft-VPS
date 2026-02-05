#!/usr/bin/env bash
set -euo pipefail

KAMI_URL="https://github.com/kami2k1/tunnel/releases/latest/download/kami-tunnel-linux-amd64.tar.gz"
ARCHIVE="kami-tunnel-linux-amd64.tar.gz"

# Install only if ./k doesn't exist
if [[ ! -f ./k ]]; then
  echo "Installing kami tunnel..."
  wget -q "$KAMI_URL" -O "$ARCHIVE"
  tar -xzf "$ARCHIVE"
  chmod +x kami-tunnel
  mv -f kami-tunnel k
  rm -f "$ARCHIVE"
else
  echo "kami tunnel already installed: ./k"
fi

# Run
./k 1980

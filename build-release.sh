#!/bin/bash
# Rebuilds this release from scratch: Alien Arena 7.72.3 from upstream, this
# repository's patch, static dependencies, and one archive per architecture.
# Needs Xcode's command line tools, cmake and python3. Usage: build-release.sh <work dir>
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; WORK="$(mkdir -p "$1" && cd "$1" && pwd)"
[ -d "$WORK/alienarena" ] || git clone --depth 1 --branch 7.72.3 https://github.com/alienarena/alienarena.git "$WORK/alienarena"
git -C "$WORK/alienarena" apply --whitespace=nowarn "$HERE/alienarena-7.72.3-macos.patch"
for arch in arm64 x86_64; do
  "$HERE/build-deps.sh" "$arch" "$WORK/deps"
  bash "$WORK/alienarena/macos/build.sh" "$arch" "$WORK/deps/prefix-$arch" "$WORK/build-$arch"
  bash "$WORK/alienarena/macos/package.sh" "$arch" "$WORK/build-$arch/alienarena" "$WORK/dist"
done

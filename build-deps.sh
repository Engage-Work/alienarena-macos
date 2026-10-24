#!/bin/bash
# Static SDL2, FreeType, libjpeg-turbo, libogg and libvorbis for one
# architecture, for macOS 11 and later. Usage: build-deps.sh <arm64|x86_64> <work dir>
set -euo pipefail
ARCH="$1"; WORK="$2"
DL="$WORK/dl"; SRC="$WORK/src-$ARCH"; PREFIX="$WORK/prefix-$ARCH"
mkdir -p "$DL" "$SRC" "$PREFIX"
export MACOSX_DEPLOYMENT_TARGET=11.0

fetch() { # url sha256
  local f="$DL/$(basename "$1")"
  [ -s "$f" ] || curl -fsSL -o "$f" "$1"
  echo "$2  $f" | shasum -a 256 -c - >/dev/null
  tar -xf "$f" -C "$SRC"
}
fetch https://github.com/libsdl-org/SDL/releases/download/release-2.32.10/SDL2-2.32.10.tar.gz 5f5993c530f084535c65a6879e9b26ad441169b3e25d789d83287040a9ca5165
fetch https://download.savannah.gnu.org/releases/freetype/freetype-2.13.3.tar.xz 0550350666d427c74daeb85d5ac7bb353acba5f76956395995311a9c6f063289
fetch https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/3.1.2/libjpeg-turbo-3.1.2.tar.gz 8f0012234b464ce50890c490f18194f913a7b1f4e6a03d6644179fa0f867d0cf
fetch https://downloads.xiph.org/releases/ogg/libogg-1.3.6.tar.xz 5c8253428e181840cd20d41f3ca16557a9cc04bad4a3d04cce84808677fa1061
fetch https://downloads.xiph.org/releases/vorbis/libvorbis-1.3.7.tar.xz b33cc4934322bcbf6efcbacf49e3ca01aadbea4114ec9589d1b1e9d20f72954b

common=(-G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES="$ARCH"
  -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 -DCMAKE_INSTALL_PREFIX="$PREFIX" -DCMAKE_PREFIX_PATH="$PREFIX"
  -DBUILD_SHARED_LIBS=OFF -DCMAKE_POLICY_VERSION_MINIMUM=3.5
  -DCMAKE_IGNORE_PREFIX_PATH="/opt/homebrew;/usr/local")
build() { # dir, cmake args...
  local d="$1"; shift
  cmake -S "$SRC/$d" -B "$SRC/$d/b" "${common[@]}" "$@" >"$SRC/$d.log" 2>&1
  cmake --build "$SRC/$d/b" -j8 >>"$SRC/$d.log" 2>&1
  cmake --install "$SRC/$d/b" >>"$SRC/$d.log" 2>&1
  echo "$ARCH $d ok"
}
build libogg-1.3.6
build libvorbis-1.3.7
build freetype-2.13.3 -DFT_DISABLE_PNG=ON -DFT_DISABLE_HARFBUZZ=ON -DFT_DISABLE_BROTLI=ON -DFT_DISABLE_BZIP2=ON -DFT_DISABLE_ZLIB=ON
# libjpeg-turbo's x86 SIMD needs nasm; texture loading doesn't need it.
build libjpeg-turbo-3.1.2 -DENABLE_SHARED=OFF -DWITH_TURBOJPEG=OFF $( [ "$ARCH" = x86_64 ] && echo -DWITH_SIMD=OFF )
build SDL2-2.32.10 -DSDL_SHARED=OFF -DSDL_STATIC=ON -DSDL_TEST=OFF

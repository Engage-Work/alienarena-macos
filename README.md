# Alien Arena for macOS

Native macOS builds of [Alien Arena](https://www.alienarena.org), the free sci-fi arena shooter by COR Entertainment, made from the official source ([alienarena/alienarena](https://github.com/alienarena/alienarena) at tag `7.72.3`, commit `0b40849e`). The [releases](../../releases) hold the complete game, for Apple silicon and for Intel Macs, running on macOS 11 or later.

Upstream ships Windows and Linux builds. Its Unix client draws through X11, which macOS doesn't have, so this build replaces that one layer and keeps the rest of the engine and all of the game data as they are.

## What the patch changes

`alienarena-7.72.3-macos.patch` applies to upstream 7.72.3:

- `source/unix/gl_sdl.c` is a new SDL2 window, OpenGL context and input layer, used in place of `gl_glx.c`. It keeps that file's contract with the engine.
- `qgl.h` and `qgl_unix.c` skip GLX when built with `USE_SDL`.
- `snd_openal.c`: Apple's OpenAL doesn't report `ALC_MONO_SOURCES`, so the engine generates as many sources as `s_maxsources` asks for and doesn't read an uninitialised count.
- `r_main.c`: Apple's OpenGL crashes copying the screen into a texture that generates its own mipmaps. The mirror texture now makes its mipmaps after the copy.
- `acebot_spawn.c`: an overlapping `strcpy` when adding an unnamed bot, which macOS stops at runtime.
- `macos/` holds a hand-written `config.h`, Mesa's `GL/gl.h`, a build script that compiles the same sources as `source/Makefile.am`, and the packaging script.

## Building

```sh
./build-release.sh /path/to/work
```

This clones upstream, applies the patch, builds static SDL2 2.32.10, FreeType 2.13.3, libjpeg-turbo 3.1.2, libogg 1.3.6 and libvorbis 1.3.7 for each architecture (`build-deps.sh`, checksums pinned), compiles the game, and writes `alienarena-7.72.3-macos-<arch>.tar.gz` to `work/dist`. curl, zlib, OpenGL and OpenAL come from macOS.

## Licences

The engine source and this patch are GPL v2 or later (`COPYING`). The game data (maps, models, textures, sounds) is COR Entertainment's and may be redistributed only as the whole game, which each release archive is; see `docs/license.txt` inside it. The archives also link SDL2 (zlib), FreeType (FTL), libjpeg-turbo (IJG/BSD), and libogg and libvorbis (BSD).

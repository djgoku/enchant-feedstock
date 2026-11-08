#!/bin/bash
set -euxo pipefail

export PKG_CONFIG="$BUILD_PREFIX/bin/pkg-config"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
export OBJCXX="$CXX"
export OBJCXXFLAGS="$CXXFLAGS"

export GLIB_CFLAGS="-I$PREFIX/include/glib-2.0 -I$PREFIX/lib/glib-2.0/include"
export GLIB_LIBS="-L$PREFIX/lib -lglib-2.0 -lgobject-2.0 -lgmodule-2.0 -lgio-2.0"

autoreconf -vfi
./configure --prefix=$PREFIX \
  --disable-static \
  --enable-relocatable \
  --with-hunspell \
  $([[ "$target_platform" == osx-* ]] && echo --with-applespell)
make -j"${CPU_COUNT}"
make install

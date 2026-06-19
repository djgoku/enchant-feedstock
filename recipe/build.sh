#!/bin/bash

export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH

export GLIB_CFLAGS="-I$PREFIX/include/glib-2.0 -I$PREFIX/lib/glib-2.0/include"
export GLIB_LIBS="-L$PREFIX/lib -lglib-2.0 -lgobject-2.0 -lgmodule-2.0 -lgio-2.0"

# hunspell provider: pkg-config detection fails in this build (same reason the
# GLIB_* flags are set by hand above), so the hunspell PKG_CHECK_MODULES check
# silently fails and the provider is skipped (WITH_HUNSPELL=no) -> a providerless
# enchant. Pass the flags explicitly; PKG_CHECK_MODULES skips pkg-config when
# both *_CFLAGS and *_LIBS are pre-set, giving WITH_HUNSPELL=yes.
export HUNSPELL_CFLAGS="-I$PREFIX/include/hunspell"
export HUNSPELL_LIBS="-L$PREFIX/lib -lhunspell-1.7"

# applespell provider (macOS only): needs the Objective-C++ compiler and the
# Cocoa framework from the macOS SDK. Guard by target_platform so the Linux
# build (no Cocoa) is unaffected.
EXTRA_CONFIG=""
if [[ "$target_platform" == osx-* ]]; then
  export OBJCXX="$CXX"
  EXTRA_CONFIG="--with-applespell"
fi

autoreconf -vfi
./configure --prefix=$PREFIX \
  --disable-static \
  --enable-relocatable \
  --disable-vala \
  $EXTRA_CONFIG \
  CFLAGS="-I$PREFIX/include" \
  LDFLAGS="-L$PREFIX/lib"
make
make install

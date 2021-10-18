#pragma once

#include <stddef.h>

// The original definition of lua_getlocaledecpoint() in luaconf.h requires
// localeconv(). lua_getlocaledecpoint() has been overridden in build.zig
// to remove this requirement. However, locale.h is included wherever
// lua_getlocaledecpoint() is used, so this header still needs to exist.

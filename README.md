Odin bindings for [Daxa's](https://github.com/Ipotrick/Daxa) C api

Includes binaries for x64 windows

## Build notes:

If you're building it yourself following the official instructions you can disable all the optional features (Task Graph, Pipeline Manager, Mem etc) because they're not part of the C api.

Additionally either build as a dll (set BUILD_SHARED_LIBS to true in CMAKE) or using the static CRT(set DAXA_USE_STATIC_CRT to true in CMAKE) to avoid linking issues with Odin.

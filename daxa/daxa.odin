package daxa

// @(require, extra_linker_flags="/NODEFAULTLIB:libcmt")
foreign import lib "daxa.lib"
_ :: lib

@(require)
foreign import __ "vulkan-1.lib"


@echo off
glslc -fshader-stage=vertex ^
      -DDAXA_SHADER_STAGE=DAXA_SHADER_STAGE_VERTEX ^
      -I. ^
      -I"../../daxa/include" ^
      main.glsl ^
      -o vert.spv

glslc -fshader-stage=fragment ^
      -DDAXA_SHADER_STAGE=DAXA_SHADER_STAGE_FRAGMENT ^
      -I. ^
      -I"../../daxa/include" ^
      main.glsl ^
      -o frag.spv

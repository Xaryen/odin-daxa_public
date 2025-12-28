@echo off
glslc -fshader-stage=compute^
      -DDAXA_SHADER_STAGE=DAXA_SHADER_STAGE_VERTEX ^
      -I. ^
      -I"../../daxa/include" ^
      compute.glsl ^
      -o comp.spv

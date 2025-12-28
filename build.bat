@echo off

rem odin run . -debug -keep-executable -sanitize=address -show-timings -vet-shadowing 
odin run . -debug -keep-executable -show-timings -vet-shadowing
rem odin run . -keep-executable -o:speed -show-timings -vet-shadowing
cmake_minimum_required(VERSION 3.20)
project(MixedAsmC C ASM_NASM)

set_source_files_properties(src/add_u64.asm PROPERTIES LANGUAGE ASM_NASM)

add_executable(mix_app
  src/main.c
  src/add_u64.asm
)

target_compile_options(mix_app PRIVATE -Wall -Wextra)

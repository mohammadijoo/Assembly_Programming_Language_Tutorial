cmake_minimum_required(VERSION 3.20)
project(CMakeAsmWorkflow C ASM_NASM)

if(NOT CMAKE_ASM_NASM_COMPILER)
  message(FATAL_ERROR "NASM not found. Install NASM or set ASM_NASM to the nasm executable.")
endif()

add_executable(app_nasm
  src/main_nasm.asm
  src/print_nasm.asm
)
set_source_files_properties(
  src/main_nasm.asm
  src/print_nasm.asm
  PROPERTIES LANGUAGE ASM_NASM
)
target_include_directories(app_nasm PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)

add_executable(mix_app
  src/main.c
  src/add_u64.asm
)
set_source_files_properties(src/add_u64.asm PROPERTIES LANGUAGE ASM_NASM)

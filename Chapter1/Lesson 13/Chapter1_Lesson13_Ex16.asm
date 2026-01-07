cmake_minimum_required(VERSION 3.20)
project(AsmWorkflowDemo C ASM_NASM)

# If your NASM files end with .asm, you may need to explicitly set the language:
set_source_files_properties(
  src/main_nasm.asm
  src/print_nasm.asm
  PROPERTIES LANGUAGE ASM_NASM
)

add_executable(app_nasm
  src/main_nasm.asm
  src/print_nasm.asm
)

target_include_directories(app_nasm PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)

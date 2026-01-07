; NASM-style sectioning (linker/loader concept, not CPU segmentation):
section .text
global my_func
my_func:
  ret

section .data
my_value: dd 123

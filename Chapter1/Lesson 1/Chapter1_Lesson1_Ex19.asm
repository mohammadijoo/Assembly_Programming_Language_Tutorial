; hello_macro.asm
%include "sys_linux_x64.inc"

section .rodata
msg:    db "Hello, Assembly via macros!", 10
msg_len equ $ - msg

section .text
global _start
_start:
  SYSCALL3 SYS_write, FD_STDOUT, msg, msg_len

  mov eax, SYS_exit
  xor edi, edi
  syscall
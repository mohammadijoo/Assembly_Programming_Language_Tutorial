
; main.asm
BITS 64
global _start

%include "sys_linux_x64.inc"

section .text
_start:
  mov eax, SYS_write
  mov edi, STDOUT_FD
  lea rsi, [rel msg]
  mov edx, msg_len
  syscall

  mov eax, SYS_exit
  xor edi, edi
  syscall

section .rodata
msg db "Includes are the assembly equivalent of headers.", 10
msg_len equ $ - msg
      
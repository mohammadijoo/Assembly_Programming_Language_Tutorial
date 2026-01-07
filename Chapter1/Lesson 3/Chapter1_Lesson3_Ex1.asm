; NASM (Intel syntax), Linux x86-64
; Demonstrates: entry point _start, direct syscalls, RIP-relative addressing

global _start

section .data
  msg db "Assembly speaks to the OS directly.", 10
  len equ $ - msg

section .text
_start:
  ; write(1, msg, len)
  mov eax, 1                ; SYS_write
  mov edi, 1                ; fd = STDOUT
  lea rsi, [rel msg]        ; buf
  mov edx, len              ; count
  syscall

  ; exit(0)
  mov eax, 60               ; SYS_exit
  xor edi, edi              ; status = 0
  syscall

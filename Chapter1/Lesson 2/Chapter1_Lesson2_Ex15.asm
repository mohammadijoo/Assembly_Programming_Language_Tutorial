
; --- (3) 64-bit Linux syscall ---
BITS 64
global _start
section .text
_start:
  mov eax, 9
  add eax, eax      ; eax = 18
  add eax, 5        ; eax = 23

  mov edi, eax      ; status in rdi
  mov eax, 60       ; SYS_exit (x86-64)
  syscall
      
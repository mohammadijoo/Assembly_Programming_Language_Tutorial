
; --- (2) 32-bit Linux int 0x80 ---
BITS 32
global _start
section .text
_start:
  mov eax, 9
  add eax, eax      ; eax = 18
  add eax, 5        ; eax = 23

  mov ebx, eax      ; status
  mov eax, 1        ; SYS_exit (x86 32-bit)
  int 0x80
      
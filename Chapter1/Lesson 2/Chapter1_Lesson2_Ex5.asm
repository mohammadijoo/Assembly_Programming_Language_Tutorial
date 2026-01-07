
; ---------- module_a.asm ----------
BITS 64
global _start
extern worker

section .text
_start:
  ; Call worker() in another module
  call worker

  ; Exit with code returned in eax (Linux x86-64 convention for syscall args)
  mov edi, eax
  mov eax, 60
  syscall
      

; ---------- module_b.asm ----------
BITS 64
global worker

section .text
worker:
  ; Compute something non-trivial without libc:
  ; return (3 * 7) + 1 = 22
  mov eax, 3
  imul eax, eax, 7
  add eax, 1
  ret
      

; ---------- code_mod.asm ----------
BITS 64
global _start
extern shared_value

section .text
_start:
  ; RIP-relative load (assembler/linker produce the correct relocation)
  mov rax, [rel shared_value]

  ; Mix bits to produce a small exit status (just to make it observable)
  xor eax, 0x55
  and eax, 0xFF

  mov edi, eax
  mov eax, 60
  syscall
      

; Forward reference example: jump target defined later
BITS 64

global _start
section .text
_start:
  jmp later              ; assembler must resolve target displacement

here:
  nop
  nop
  jmp done

later:
  ; In real programs, "later" may be far away, possibly forcing a different encoding.
  nop
  nop
  jmp here

done:
  ; Exit syscall (Linux x86-64): rax=60, rdi=status
  mov eax, 60
  xor edi, edi
  syscall
      
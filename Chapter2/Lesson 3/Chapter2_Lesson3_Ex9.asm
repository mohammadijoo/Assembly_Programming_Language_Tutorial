; File: isa_inspect.asm
bits 64
default rel

global _start

section .text
_start:
  ; 1) different widths
  mov al,  0x11
  mov ax,  0x2222
  mov eax, 0x33333333
  mov rax, 0x4444444444444444

  ; 2) register vs memory
  lea rbx, [rel data_qword]
  mov rcx, [rbx]
  add rcx, 5

  ; 3) demonstrate flag usage
  sub rcx, rcx
  jz  .zero

  ud2              ; should be unreachable
.zero:
  ; Linux x86-64 exit(0)
  mov eax, 60
  xor edi, edi
  syscall

section .data
data_qword: dq 0x1122334455667788

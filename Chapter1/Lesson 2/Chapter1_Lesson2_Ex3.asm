
; NASM macro example: save/restore a chosen register set
; (Demonstrates "macro assembler" evolution: abstraction without runtime overhead.)

%macro SAVE_GPRS 0
  push rbx
  push rbp
  push r12
  push r13
  push r14
  push r15
%endmacro

%macro RESTORE_GPRS 0
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbp
  pop rbx
%endmacro

global _start
section .text
_start:
  SAVE_GPRS

  ; Do something observable (exit code = 7)
  mov eax, 60
  mov edi, 7

  RESTORE_GPRS
  syscall
      
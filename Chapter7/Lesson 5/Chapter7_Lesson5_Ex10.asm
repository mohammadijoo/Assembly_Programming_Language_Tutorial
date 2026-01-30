; Chapter7_Lesson5_Ex10.asm
; NASM "header-style" building blocks for memory-optimized code:
;   - compile-time alignment helpers
;   - stack-frame macros that preserve 16-byte alignment
;   - patterns you can reuse across hot routines
;
; In practice you place these macros in a separate file and %include it.
; Assemble (standalone demo): nasm -felf64 Chapter7_Lesson5_Ex10.asm && ld -o ex10 Chapter7_Lesson5_Ex10.o

BITS 64
default rel

%define SYS_exit 60

; ---------------------------
; Compile-time helpers
; ---------------------------
; ROUND_UP(expr, align_pow2) works for constant expressions.
%define ROUND_UP(x,a) (((x) + ((a)-1)) & - (a))

; ---------------------------
; Stack-frame macros
; ---------------------------
%macro PROLOGUE_ALIGNED 1
  push rbp
  mov rbp, rsp
  sub rsp, ROUND_UP(%1, 16)
%endmacro

%macro EPILOGUE 0
  mov rsp, rbp
  pop rbp
  ret
%endmacro

; ------------------------------------------
; u64 scratch_example(void)
; Demonstrates an aligned scratch buffer local to the callee.
; ------------------------------------------
global scratch_example
scratch_example:
  PROLOGUE_ALIGNED 96
  ; RSP is 16-aligned here. Use [rsp..rsp+95] as scratch.
  mov qword [rsp + 0], 0x0123456789ABCDEF
  mov qword [rsp + 8], 0x1111111111111111
  mov rax, [rsp + 0]
  add rax, [rsp + 8]
  EPILOGUE

section .text
global _start

_start:
  and rsp, -16
  call scratch_example

  mov eax, SYS_exit
  xor edi, edi
  syscall

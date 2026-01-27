; Chapter 6 - Lesson 7 - Example 5
; Title: ABI-portable argument register mapping (SysV vs Win64) using NASM conditionals
;
; Build:
;   Linux SysV:  nasm -felf64 Chapter6_Lesson7_Ex5.asm -o ex5.o && ld -o ex5 ex5.o
;   Windows:     nasm -fwin64 Chapter6_Lesson7_Ex5.asm -DWIN64 -o ex5.obj
;
; This file is intentionally "header-like": it demonstrates macro patterns you can reuse.

BITS 64
DEFAULT REL

%ifdef WIN64
  %define ARG1 rcx
  %define ARG2 rdx
  %define ARG3 r8
  %define ARG4 r9
  %define SHADOW_BYTES 32
%else
  %define ARG1 rdi
  %define ARG2 rsi
  %define ARG3 rdx
  %define ARG4 rcx
  %define SHADOW_BYTES 0
%endif

GLOBAL add4_u64

SECTION .text

; uint64_t add4_u64(uint64_t a, uint64_t b, uint64_t c, uint64_t d)
; Returns a+b+c+d in RAX.
add4_u64:
    ; This function is leaf and does not call out, so it only needs to obey:
    ;   - preserve callee-saved regs (we don't touch them)
    ;   - return value in RAX
    mov rax, ARG1
    add rax, ARG2
    add rax, ARG3
    add rax, ARG4
    ret

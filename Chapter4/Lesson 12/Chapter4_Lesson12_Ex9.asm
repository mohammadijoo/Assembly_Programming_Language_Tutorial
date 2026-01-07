; Chapter 4 - Lesson 12 (Ex9)
; "Header-like" helper macros to avoid common pitfalls.
; Keep this in a separate file in real projects (e.g., pitfalls.inc) and %include it.
; Here we keep it as a single .asm for portability with the lesson packaging.

bits 64
default rel
global _start

; ----------------------------
; Macro: SAVE_FLAGS / RESTORE_FLAGS
; ----------------------------
%macro SAVE_FLAGS 0
    pushfq
%endmacro

%macro RESTORE_FLAGS 0
    popfq
%endmacro

; ----------------------------
; Macro: DIVU64_CHECKED
; Unsigned divide (RDX:RAX) / reg64
; - If divisor==0 or overflow (RDX >= divisor), set CF=1 and return without DIV
; - Else perform DIV and set CF=0
; Inputs: RDX:RAX numerator, %1 divisor (reg64 or mem64)
; Outputs: RAX quotient, RDX remainder, CF indicates error
; ----------------------------
%macro DIVU64_CHECKED 1
    ; Denominator must be non-zero
    cmp     %1, 0
    je      %%err_zero

    ; Overflow if high half >= divisor (then quotient would not fit 64 bits)
    cmp     rdx, %1
    jae     %%err_overflow

    div     %1
    clc
    jmp     %%done

%%err_zero:
    stc
    jmp     %%done

%%err_overflow:
    stc

%%done:
%endmacro

; ----------------------------
; Macro: BOOL_FROM_FLAGS
; Convert condition into 0/1 cleanly without partial-register hazards.
; Usage: BOOL_FROM_FLAGS al, setcc_mnemonic  (e.g., BOOL_FROM_FLAGS al, setl)
; Ensures EAX is clean boolean (0/1).
; ----------------------------
%macro BOOL_FROM_FLAGS 2
    %2      %1                  ; e.g., setl al
    movzx   eax, %1             ; clear upper bits, make boolean in EAX/RAX
%endmacro

section .text
_start:
    ; Example use: checked division 1000/7
    mov     rax, 1000
    xor     edx, edx
    mov     rcx, 7
    DIVU64_CHECKED rcx          ; uses implicit RDX:RAX for div; CF indicates errors

    ; Example use: boolean from compare without partial-reg hazard
    mov     r8,  5
    mov     r9,  9
    cmp     r8, r9
    BOOL_FROM_FLAGS al, setl    ; EAX becomes 1 if r8 < r9 else 0

    mov     eax, 60
    xor     edi, edi
    syscall

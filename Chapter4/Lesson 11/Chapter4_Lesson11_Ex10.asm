; Chapter 4 - Lesson 11 (Exercise Solution 2)
; Median of three signed 64-bit integers using only CMOV-based compare-swaps
; (a small sorting network; no data-dependent branches).
;
; This file is a self-test harness:
;   prints PASS or FAIL and exits with 0/1.

bits 64
default rel
%include "Chapter4_Lesson11_Ex8.asm"

section .rodata
msg_pass db "PASS", 10
len_pass equ $-msg_pass
msg_fail db "FAIL", 10
len_fail equ $-msg_fail

section .text
global _start

%macro CSWAP64_SIGNED 2
    ; compare-swap registers (signed): ensures %1 <= %2
    mov r8, %1
    mov r9, %2
    cmp r8, r9
    cmovg %1, r9
    cmovg %2, r8
%endmacro

; ------------------------------------------------------------
; median3_s64
;   Inputs : RDI=a, RSI=b, RDX=c (signed 64-bit)
;   Output : RAX=median(a,b,c)
;   Clobbers: R8, R9
; ------------------------------------------------------------
median3_s64:
    mov rax, rdi
    mov rbx, rsi
    mov rcx, rdx

    ; Sorting network:
    ; 1) sort (a,b)
    CSWAP64_SIGNED rax, rbx
    ; 2) sort (b,c)
    CSWAP64_SIGNED rbx, rcx
    ; 3) sort (a,b) again
    CSWAP64_SIGNED rax, rbx

    ; Now rbx is the median
    mov rax, rbx
    ret

_start:
    ; Test 1: (3, 1, 2) -> 2
    mov rdi, 3
    mov rsi, 1
    mov rdx, 2
    call median3_s64
    cmp rax, 2
    jne .fail

    ; Test 2: (-10, 7, 7) -> 7
    mov rdi, -10
    mov rsi, 7
    mov rdx, 7
    call median3_s64
    cmp rax, 7
    jne .fail

    ; Test 3: (INT64_MIN, 0, INT64_MAX) -> 0
    mov rdi, 0x8000000000000000
    mov rsi, 0
    mov rdx, 0x7FFFFFFFFFFFFFFF
    call median3_s64
    cmp rax, 0
    jne .fail

    WRITE msg_pass, len_pass
    EXIT 0

.fail:
    WRITE msg_fail, len_fail
    EXIT 1

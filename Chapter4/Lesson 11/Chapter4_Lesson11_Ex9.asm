; Chapter 4 - Lesson 11 (Exercise Solution 1)
; Signed 32-bit saturating addition WITHOUT branching in the core operation.
;   sat_add32(a,b) = clamp(a+b, INT32_MIN, INT32_MAX)
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

; ------------------------------------------------------------
; sat_add32
;   Inputs : EDI=a, ESI=b (signed 32-bit)
;   Output : EAX=saturating(a+b)
;   Clobbers: ECX, EDX, R8D, R10D
; ------------------------------------------------------------
sat_add32:
    mov eax, edi
    mov r8d, edi                ; save sign of a (overflow implies same sign operands)
    add eax, esi                ; sets OF if overflow
    seto dl                     ; save overflow to DL (0/1)

    ; sat = (a < 0) ? INT32_MIN : INT32_MAX
    mov ecx, 0x7FFFFFFF
    mov r10d, 0x80000000
    cmp r8d, 0
    cmovl ecx, r10d

    ; if overflow (DL=1) then EAX = sat
    test dl, dl
    cmovne eax, ecx
    ret

_start:
    ; Test 1: 100 + 50 = 150
    mov edi, 100
    mov esi, 50
    call sat_add32
    cmp eax, 150
    jne .fail

    ; Test 2: INT32_MAX-15 + 256 -> saturate to INT32_MAX
    mov edi, 0x7FFFFFF0
    mov esi, 0x00000100
    call sat_add32
    cmp eax, 0x7FFFFFFF
    jne .fail

    ; Test 3: INT32_MIN+16 + (-256) -> saturate to INT32_MIN
    mov edi, 0x80000010
    mov esi, -256
    call sat_add32
    cmp eax, 0x80000000
    jne .fail

    ; PASS
    WRITE msg_pass, len_pass
    EXIT 0

.fail:
    WRITE msg_fail, len_fail
    EXIT 1

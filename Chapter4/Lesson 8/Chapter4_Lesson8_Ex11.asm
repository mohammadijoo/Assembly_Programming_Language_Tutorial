BITS 64
default rel

; Ex11 (Exercise Solution 1): SysV AMD64 callable multi-precision add.
; uint8_t mp_add_qwords(uint64_t* out, const uint64_t* a, const uint64_t* b, size_t n);
; Inputs:
;   rdi=out, rsi=a, rdx=b, rcx=n
; Output:
;   al = carry_out (0 or 1)
;
; This file also includes a tiny _start harness for standalone testing.

global mp_add_qwords
global _start

section .data
    A dq 0xFFFFFFFFFFFFFFFF, 0x0, 0x1, 0x2
    B dq 0x1,               0x0, 0x3, 0x4
    OUT times 4 dq 0
    carry db 0

section .text
mp_add_qwords:
    ; Early return for n=0
    test rcx, rcx
    jz .done0

    clc
.loop:
    mov r8, [rsi]
    adc r8, [rdx]
    mov [rdi], r8

    add rsi, 8
    add rdx, 8
    add rdi, 8
    dec rcx
    jnz .loop

    setc al
    ret
.done0:
    xor eax, eax
    ret

_start:
    lea rdi, [OUT]
    lea rsi, [A]
    lea rdx, [B]
    mov rcx, 4
    call mp_add_qwords
    mov [carry], al

    mov eax, 60
    xor edi, edi
    syscall

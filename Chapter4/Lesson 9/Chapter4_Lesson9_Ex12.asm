; Chapter4_Lesson9_Ex12.asm
; Exercise Solution 4: dot_u8_i8
;   int64_t dot_u8_i8(const uint8_t *a, const int8_t *b, size_t n);
; SysV ABI: RDI=a, RSI=b, RDX=n, return RAX.

BITS 64
DEFAULT REL

GLOBAL _start
GLOBAL dot_u8_i8

SECTION .data
a db 1, 2, 3, 4
b db -1, 1, -1, 1
n equ 4

SECTION .text
dot_u8_i8:
    xor rax, rax
    test rdx, rdx
    jz .done
.loop:
    movzx ecx, byte [rdi]     ; unsigned 0..255
    movsx r8d, byte [rsi]     ; signed in 32-bit
    imul r8d, ecx             ; product in r8d (signed 32-bit)
    movsxd r8, r8d            ; sign-extend product to 64-bit
    add rax, r8
    inc rdi
    inc rsi
    dec rdx
    jnz .loop
.done:
    ret

_start:
    lea rdi, [a]
    lea rsi, [b]
    mov rdx, n
    call dot_u8_i8            ; expected: 1*(-1)+2*1+3*(-1)+4*1 = 2
    mov eax, 60
    xor edi, edi
    syscall

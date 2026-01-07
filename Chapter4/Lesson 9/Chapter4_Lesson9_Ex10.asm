; Chapter4_Lesson9_Ex10.asm
; Exercise Solution 2: count_gt_u8
;   uint32_t count_gt_u8(const uint8_t *p, size_t n, uint32_t thr);
; SysV ABI: RDI=p, RSI=n, EDX=thr, return EAX.

BITS 64
DEFAULT REL

GLOBAL _start
GLOBAL count_gt_u8

SECTION .data
arr db 1, 200, 201, 0, 255, 199
len equ $-arr

SECTION .text
count_gt_u8:
    xor eax, eax
    test rsi, rsi
    jz .done
.loop:
    movzx ecx, byte [rdi]     ; ECX in [0,255]
    cmp ecx, edx
    jbe .no
    inc eax
.no:
    inc rdi
    dec rsi
    jnz .loop
.done:
    ret

_start:
    lea rdi, [arr]
    mov rsi, len
    mov edx, 200              ; count values > 200
    call count_gt_u8          ; expected count: {201,255} -> 2
    mov eax, 60
    xor edi, edi
    syscall

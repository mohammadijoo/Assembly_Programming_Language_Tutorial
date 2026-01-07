BITS 64
default rel
global _start

section .data
arr dd 10, 20, 30, 40, 50
arr_len equ ($ - arr) / 4

section .text
_start:
    ; Sum an int32 array using LOOP (RCX is the implicit counter in 64-bit mode).
    ; rsi points to current element, eax accumulates sum.

    lea rsi, [rel arr]
    mov ecx, arr_len
    xor eax, eax

    ; Handle length == 0 safely.
    jrcxz .done

.loop_body:
    add eax, dword [rsi]
    add rsi, 4
    loop .loop_body       ; RCX-- ; if RCX != 0, jump

.done:
    ; exit(sum & 0xFF)
    mov edi, eax
    mov eax, 60
    syscall

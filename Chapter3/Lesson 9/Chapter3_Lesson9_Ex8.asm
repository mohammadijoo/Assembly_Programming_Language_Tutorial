; Chapter 3 - Lesson 9
; Ex8: MOVSX/MOVZX while summing arrays (why sign-extension is non-optional for signed data)

%include "Chapter3_Lesson9_Ex1.asm"

BITS 64
default rel
global _start

section .data
hdr: db "Summing bytes with correct extension:",10,0

arr_signed: db -1, 2, -3, 4, -5, 6, -7, 8
arr_len:    equ $ - arr_signed

lbl_s: db "  Signed sum (int8 elements):   ",0
lbl_u: db "  Unsigned sum (same bytes):    ",0
lbl_w: db 10,"Now with 16-bit words (signed):",10,0
arr_words: dw -30000, 12345, -1000, 25000
w_len:    equ ($ - arr_words) / 2
lbl_ws: db "  Signed sum (int16 elements):  ",0

section .text
_start:
    PRINTZ hdr

    ; Signed sum: sum += signext(byte)
    xor rax, rax
    mov rcx, arr_len
    lea rsi, [arr_signed]
.s_loop:
    movsx rdx, byte [rsi]
    add rax, rdx
    inc rsi
    dec rcx
    jnz .s_loop

    PRINTZ lbl_s
    call print_i64_nl

    ; Unsigned sum: sum += zeroext(byte)
    xor rax, rax
    mov rcx, arr_len
    lea rsi, [arr_signed]
.u_loop:
    movzx rdx, byte [rsi]
    add rax, rdx
    inc rsi
    dec rcx
    jnz .u_loop

    PRINTZ lbl_u
    call print_u64_nl

    ; Signed word sum using MOVSX from memory
    PRINTZ lbl_w
    xor rax, rax
    mov rcx, w_len
    lea rsi, [arr_words]
.w_loop:
    movsx rdx, word [rsi]
    add rax, rdx
    add rsi, 2
    dec rcx
    jnz .w_loop

    PRINTZ lbl_ws
    call print_i64_nl

    jmp exit0

BITS 64
default rel
global _start

%include "Chapter4_Lesson7_Ex5.asm"

section .data
msg db "Counted bytes until NUL using JZ/JMP loop.", 10, 0

section .text
_start:
    ; Demonstrate a classic "while (*p != 0) { count++; p++; }" loop in NASM.
    ; We keep it explicit with TEST/JZ and an unconditional back-edge JMP.

    lea rsi, [rel msg]     ; pointer p
    xor ecx, ecx           ; count = 0

.loop:
    mov al, [rsi]
    test al, al
    jz .done               ; exit when NUL seen (ZF=1)
    inc ecx
    inc rsi
    jmp .loop

.done:
    ; Print the message (for a visible run) and exit with count & 0xFF
    lea rsi, [rel msg]
    call print_cstr
    mov edi, ecx
    SYS_EXIT edi

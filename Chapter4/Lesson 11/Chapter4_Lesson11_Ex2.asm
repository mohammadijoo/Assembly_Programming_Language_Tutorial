; Chapter 4 - Lesson 11 (Example 2)
; SETcc writes only an 8-bit destination. If you later read EAX/RAX,
; the upper bits are NOT automatically cleared (partial-register pitfall).
; This program prints:
;   (1) an unsafe boolean (upper bits preserved)
;   (2) safe pattern: XOR reg,reg; SETcc
;   (3) safe pattern: SETcc; MOVZX

bits 64
default rel
%include "Chapter4_Lesson11_Ex8.asm"

section .text
global _start

_start:
    ; --------------------------------
    ; Unsafe: AL=0/1, but EAX keeps old upper 24 bits
    mov eax, 0x12345600
    mov ebx, 0x12345600
    cmp ebx, 0x12345600
    setne al                ; expected boolean 0, but EAX becomes 0x12345600

    mov rdi, rax
    call print_hex_u64

    ; --------------------------------
    ; Safe A: clear the full register first
    xor eax, eax
    cmp ebx, 0x12345600
    setne al                ; EAX is now 0 or 1

    mov rdi, rax
    call print_hex_u64

    ; --------------------------------
    ; Safe B: explicitly zero-extend after SETcc
    mov eax, 0xFFFFFFFF
    cmp ebx, 0x12345600
    sete al
    movzx eax, al           ; EAX becomes 0 or 1

    mov rdi, rax
    call print_hex_u64

    EXIT 0

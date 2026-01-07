; Chapter 2 - Lesson 5 - Ex5 (Intel syntax, NASM/YASM)
; Demonstrates explicit memory sizes (BYTE/WORD/DWORD) and (zero/sign) extension loads.
; int load_store_demo(unsigned char* p, unsigned int v)
bits 64
default rel

section .text
global load_store_demo

load_store_demo:
    ; Inputs: RDI = p, ESI = v (lower 32 bits)
    mov byte  [rdi],   0x7f        ; store 8-bit immediate
    mov word  [rdi+1], 0xff80      ; store 16-bit immediate (-128)
    mov dword [rdi+3], esi         ; store 32-bit value

    movzx eax, byte [rdi]          ; zero-extend 8 -> 32
    movsx ecx, word [rdi+1]        ; sign-extend 16 -> 32
    mov edx, dword [rdi+3]         ; load 32

    add eax, ecx
    add eax, edx
    ret

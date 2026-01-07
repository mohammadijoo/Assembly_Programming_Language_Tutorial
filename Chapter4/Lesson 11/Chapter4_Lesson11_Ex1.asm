; Chapter 4 - Lesson 11 (Example 1)
; SETcc: signed vs unsigned comparisons produce different booleans.
; Output:
;   line1: signed (a < b) in hex (0x...0000 or 0x...0001)
;   line2: unsigned (a < b) in hex

bits 64
default rel
%include "Chapter4_Lesson11_Ex8.asm"

section .text
global _start

_start:
    ; a = -1 (0xFFFFFFFF), b = 1
    mov eax, -1
    mov ebx, 1

    ; signed less-than: (a < b) as signed 32-bit
    cmp eax, ebx
    xor ecx, ecx
    setl cl                 ; CL = 1 if (SF XOR OF)=1 and ZF=0

    ; unsigned less-than: (a < b) as unsigned 32-bit
    cmp eax, ebx
    xor edx, edx
    setb dl                 ; DL = 1 if CF=1

    movzx rdi, cl
    call print_hex_u64
    movzx rdi, dl
    call print_hex_u64

    EXIT 0

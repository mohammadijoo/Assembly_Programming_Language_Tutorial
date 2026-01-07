; Chapter3_Lesson1_Ex7.asm
; Lesson goal: Operand size matters: partial-register writes and zero-extension.
; Build:
;   nasm -felf64 Chapter3_Lesson1_Ex7.asm -o ex7.o
;   ld ex7.o -o ex7
; Run:
;   ./ex7

%include "Chapter3_Lesson1_Ex1.asm"
default rel

section .rodata
intro db "Partial register write effects:", 10, 0
m0 db "  Initial RAX = 0x", 0
m1 db "  After mov al,0xAA -> RAX = 0x", 0
m2 db "  After mov ax,0xBBBB -> RAX = 0x", 0
m3 db "  After mov eax,0xCCCCDDDD -> RAX = 0x", 0
m4 db "  After mov ah,0x11 -> RAX = 0x", 0

section .text
global _start
_start:
    lea rdi, [intro]
    call write_z

    mov rax, 0x1122334455667788
    lea rdi, [m0]
    call write_str_and_hex64

    mov al, 0xAA              ; modifies low 8 bits only
    lea rdi, [m1]
    call write_str_and_hex64

    mov rax, 0x1122334455667788
    mov ax, 0xBBBB            ; modifies low 16 bits only
    lea rdi, [m2]
    call write_str_and_hex64

    mov rax, 0x1122334455667788
    mov eax, 0xCCCCDDDD       ; 32-bit write zero-extends into 64-bit register on x86-64
    lea rdi, [m3]
    call write_str_and_hex64

    mov rax, 0x1122334455667788
    mov ah, 0x11              ; modifies bits 8..15 only
    lea rdi, [m4]
    call write_str_and_hex64

    sys_exit 0

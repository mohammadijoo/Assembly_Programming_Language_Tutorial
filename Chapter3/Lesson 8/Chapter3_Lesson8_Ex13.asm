BITS 64
default rel
%include "Chapter3_Lesson8_Ex3.asm"

; Demonstrates a subtle but critical point in x86-64:
; - MOV r64, imm32 uses sign-extension (imm32 -> imm64)
; - MOV eax, imm32 zero-extends into RAX

section .rodata
hdr  db "Immediate size and sign-extension pitfall (x86-64 MOV):",10,0
m1   db "mov rax, 0xffffffff gives: ",0
m2   db "mov eax, 0xffffffff gives: ",0
note db "Observe: MOV r64, imm32 sign-extends; MOV eax, imm32 zero-extends to rax.",10,0

section .text
global _start

_start:
    mov rdi, STDOUT
    lea rsi, [hdr]
    call print_cstr

    mov rdi, STDOUT
    lea rsi, [m1]
    call print_cstr
    mov rax, 0xffffffff
    mov rdi, rax
    call print_hex64
    call print_nl

    mov rdi, STDOUT
    lea rsi, [m2]
    call print_cstr
    mov eax, 0xffffffff
    mov rdi, rax
    call print_hex64
    call print_nl

    mov rdi, STDOUT
    lea rsi, [note]
    call print_cstr

    mov eax, SYS_exit
    xor edi, edi
    syscall

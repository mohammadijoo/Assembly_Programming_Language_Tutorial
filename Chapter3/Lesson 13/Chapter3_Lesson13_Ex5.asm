; Chapter 3 - Lesson 13 Example 5: Classifying binary32 values (zero/subnormal/normal/inf/NaN)
; File: Chapter3_Lesson13_Ex5.asm
;
; Build:
;   nasm -felf64 Chapter3_Lesson13_Ex5.asm -o ex5.o
;   ld -o ex5 ex5.o
;   ./ex5

BITS 64
default rel

%include "Chapter3_Lesson13_Ex1.asm"
%include "Chapter3_Lesson13_Ex2.asm"

section .rodata
msg_title: db "binary32 classification demo", 0
msg_hdr:   db "format: bits  classification", 0
sp_table:
    dd 0x00000000            ; +0
    dd 0x80000000            ; -0
    dd 0x00000001            ; smallest +subnormal
    dd 0x007FFFFF            ; largest +subnormal
    dd 0x3F800000            ; +1.0
    dd 0xBF800000            ; -1.0
    dd 0x7F800000            ; +inf
    dd 0xFF800000            ; -inf
    dd 0x7FC00001            ; qNaN
    dd 0x7FA00001            ; sNaN-ish (top frac bit 0)
sp_table_end:

msg_sep:   db "  ", 0
msg_neg0:  db "  (negative zero)", 0

section .text
global _start

_start:
    lea rdi, [msg_title]
    call print_cstr
    call print_nl
    lea rdi, [msg_hdr]
    call print_cstr
    call print_nl

    lea rbx, [sp_table]

.loop:
    cmp rbx, sp_table_end
    jae .done

    mov eax, dword [rbx]      ; eax = bits

    ; print bits
    mov edi, eax
    call print_hex32

    lea rdi, [msg_sep]
    call print_cstr

    ; classify
    push rbx
    call fp32_classify        ; eax=bits -> rax=ptr
    mov rdi, rax
    call print_cstr
    pop rbx

    ; annotate negative zero
    cmp dword [rbx], 0x80000000
    jne .nl
    lea rdi, [msg_neg0]
    call print_cstr

.nl:
    call print_nl
    add rbx, 4
    jmp .loop

.done:
    mov eax, SYS_exit
    xor edi, edi
    syscall

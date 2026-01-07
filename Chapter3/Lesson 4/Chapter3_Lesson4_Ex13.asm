; Chapter 3 - Lesson 4 (Working with Constants)
; Example 13 (Exercise Solution): Macro that selects imm8 vs imm32 at assembly time

global _start
default rel

; add_const reg64, imm
; If imm fits in signed 8-bit, emit the shorter "imm8" form (sign-extended by CPU).
; Otherwise emit the imm32 form.
%macro add_const 2
    %if (%2 >= -128) && (%2 <= 127)
        add %1, byte %2
    %else
        add %1, dword %2
    %endif
%endmacro

section .data
hexdigits    db "0123456789ABCDEF"
hexbuf       db "0x0000000000000000", 10
hexbuf_len   equ $ - hexbuf

hdr          db "add_const macro: assemble-time choice of immediate size", 10
hdr_len      equ $ - hdr

lbl1         db "after add_const rax, 5:", 10
lbl1_len     equ $ - lbl1
lbl2         db "after add_const rax, 1000:", 10
lbl2_len     equ $ - lbl2
lbl3         db "after add_const rax, -7:", 10
lbl3_len     equ $ - lbl3

section .text
%define SYS_write 1
%define SYS_exit 60
%define FD_STDOUT 1

%macro write_stdout 0
    mov eax, SYS_write
    mov edi, FD_STDOUT
    syscall
%endmacro

%macro exit 0
    mov eax, SYS_exit
    syscall
%endmacro

print_hex64:
    mov rbx, rax
    lea rdi, [hexbuf + 2 + 15]
    mov rcx, 16
.loop:
    mov rax, rbx
    and eax, 0xF
    mov al, [hexdigits + rax]
    mov [rdi], al
    shr rbx, 4
    dec rdi
    loop .loop
    lea rsi, [hexbuf]
    mov edx, hexbuf_len
    write_stdout
    ret

_start:
    lea rsi, [hdr]
    mov edx, hdr_len
    write_stdout

    xor eax, eax              ; RAX = 0

    add_const rax, 5
    lea rsi, [lbl1]
    mov edx, lbl1_len
    write_stdout
    call print_hex64

    add_const rax, 1000
    lea rsi, [lbl2]
    mov edx, lbl2_len
    write_stdout
    call print_hex64

    add_const rax, -7
    lea rsi, [lbl3]
    mov edx, lbl3_len
    write_stdout
    call print_hex64

    xor edi, edi
    exit

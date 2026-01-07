; Chapter 3 - Lesson 4 (Working with Constants)
; Example 6: Address constants, RIP-relative addressing, and relocations

default rel
global _start

section .data
hexdigits    db "0123456789ABCDEF"
hexbuf       db "0x0000000000000000", 10
hexbuf_len   equ $ - hexbuf

hdr          db "Address constants: LEA [rel label] vs MOV reg, label", 10
hdr_len      equ $ - hdr

lbl1         db "lea rax, [rel msg] (RIP-relative):", 10
lbl1_len     equ $ - lbl1

lbl2         db "mov rbx, msg (absolute relocation; not PIE-friendly):", 10
lbl2_len     equ $ - lbl2

lbl3         db "difference (rbx - rax):", 10
lbl3_len     equ $ - lbl3

msg          db "Hello from .data", 10
msg_len      equ $ - msg

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

    lea rsi, [lbl1]
    mov edx, lbl1_len
    write_stdout

    lea rax, [msg]
    call print_hex64

    lea rsi, [lbl2]
    mov edx, lbl2_len
    write_stdout

    mov rbx, msg
    mov rax, rbx
    call print_hex64

    lea rsi, [lbl3]
    mov edx, lbl3_len
    write_stdout

    ; If both produce the same final address, rbx - rax == 0
    lea rax, [msg]
    mov rcx, msg
    sub rcx, rax
    mov rax, rcx
    call print_hex64

    ; Print the message itself
    lea rsi, [msg]
    mov edx, msg_len
    write_stdout

    xor edi, edi
    exit

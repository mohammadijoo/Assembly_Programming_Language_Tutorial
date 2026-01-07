BITS 64
default rel
%include "Chapter3_Lesson8_Ex3.asm"

section .rodata
hdr    db "General base conversion (2..16) using repeated division:",10,0
msgv   db "Value (decimal) = ",0
as2    db "Base 2  (minimal)  : ",0
as10   db "Base 10 (minimal)  : ",0
as16   db "Base 16 (minimal)  : ",0
prefix db "  prefix view: ",0
p2     db "0b",0
p16    db "0x",0

section .bss
buf resb 80

section .text
global _start

_start:
    mov rdi, STDOUT
    lea rsi, [hdr]
    call print_cstr

    mov rbx, 1234567890123456789

    mov rdi, STDOUT
    lea rsi, [msgv]
    call print_cstr
    mov rdi, rbx
    call print_dec_u64
    call print_nl

    ; Base 2
    mov rdi, STDOUT
    lea rsi, [as2]
    call print_cstr
    mov rdi, rbx
    lea rsi, [buf]
    mov edx, 2
    call utoa_base
    mov rdx, rax
    mov rdi, STDOUT
    lea rsi, [buf]
    call write_buf
    call print_nl

    ; Base 10
    mov rdi, STDOUT
    lea rsi, [as10]
    call print_cstr
    mov rdi, rbx
    lea rsi, [buf]
    mov edx, 10
    call utoa_base
    mov rdx, rax
    mov rdi, STDOUT
    lea rsi, [buf]
    call write_buf
    call print_nl

    ; Base 16
    mov rdi, STDOUT
    lea rsi, [as16]
    call print_cstr
    mov rdi, rbx
    lea rsi, [buf]
    mov edx, 16
    call utoa_base
    mov rdx, rax
    mov rdi, STDOUT
    lea rsi, [buf]
    call write_buf
    call print_nl

    ; Prefix view using fixed-width printers (debug style)
    mov rdi, STDOUT
    lea rsi, [prefix]
    call print_cstr
    mov rdi, rbx
    call print_hex64
    call print_nl

    mov rdi, STDOUT
    lea rsi, [prefix]
    call print_cstr
    mov rdi, rbx
    call print_bin64
    call print_nl

    mov eax, SYS_exit
    xor edi, edi
    syscall

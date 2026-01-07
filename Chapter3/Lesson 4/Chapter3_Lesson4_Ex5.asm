; Chapter 3 - Lesson 4 (Working with Constants)
; Example 5: Using '$ - label' to compute constant lengths and sizes

global _start

section .data
hexdigits    db "0123456789ABCDEF"
hexbuf       db "0x0000000000000000", 10
hexbuf_len   equ $ - hexbuf

msg          db "String length and array size are constants you can compute at assembly time.", 10
msg_len      equ $ - msg

arr          dd 10, 20, 30, 40, 50, 60, 70
arr_bytes    equ $ - arr
arr_elems    equ arr_bytes / 4

lbl1         db "arr_bytes: ", 0
lbl2         db "arr_elems: ", 0

nl           db 10

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

print_cstr:
    push rax
    push rcx
    xor ecx, ecx
.len:
    cmp byte [rsi + rcx], 0
    je .go
    inc rcx
    jmp .len
.go:
    mov eax, SYS_write
    mov edi, FD_STDOUT
    mov rdx, rcx
    syscall
    pop rcx
    pop rax
    ret

print_hex64:
    mov rbx, rax
    lea rdi, [rel hexbuf + 2 + 15]
    mov rcx, 16
.loop:
    mov rax, rbx
    and eax, 0xF
    mov al, [rel hexdigits + rax]
    mov [rdi], al
    shr rbx, 4
    dec rdi
    loop .loop
    lea rsi, [rel hexbuf]
    mov edx, hexbuf_len
    write_stdout
    ret

_start:
    ; msg_len is computed by the assembler; no runtime strlen needed
    lea rsi, [rel msg]
    mov edx, msg_len
    write_stdout

    lea rsi, [rel lbl1]
    call print_cstr
    mov rax, arr_bytes
    call print_hex64

    lea rsi, [rel lbl2]
    call print_cstr
    mov rax, arr_elems
    call print_hex64

    lea rsi, [rel nl]
    mov edx, 1
    write_stdout

    xor edi, edi
    exit

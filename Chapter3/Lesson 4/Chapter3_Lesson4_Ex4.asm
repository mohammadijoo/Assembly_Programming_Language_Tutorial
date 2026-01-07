; Chapter 3 - Lesson 4 (Working with Constants)
; Example 4: EQU vs %define vs %assign, and compile-time assertions

global _start

; --- compile-time assertion macro (NASM preprocessor) ---
%macro STATIC_ASSERT 2
    %if not (%1)
        %error %2
    %endif
%endmacro

; EQU: defines an absolute numeric constant (cannot be redefined)
BUF_SZ      equ 64

; %define: textual substitution (can be redefined)
%define MODE_TEXT "MODE=A"
%define MODE_TEXT "MODE=B"    ; last definition wins

; %assign: arithmetic assignment (can be updated)
%assign ITER 0
%assign ITER ITER + 4

; Derive related constants at assembly time
BUF_MASK    equ BUF_SZ - 1
STATIC_ASSERT ((BUF_SZ & BUF_MASK) = 0), "BUF_SZ must be a power of two"

global _start

section .data
hexdigits    db "0123456789ABCDEF"
hexbuf       db "0x0000000000000000", 10
hexbuf_len   equ $ - hexbuf

hdr          db "Preprocessor constants and compile-time checks", 10
hdr_len      equ $ - hdr

line1        db "BUF_SZ (equ): ", 0
line1_len    equ $ - line1 - 1

line2        db "BUF_MASK (equ): ", 0
line2_len    equ $ - line2 - 1

line3        db "ITER (%assign): ", 0
line3_len    equ $ - line3 - 1

line4        db "MODE_TEXT (%define textual): ", 0
line4_len    equ $ - line4 - 1

nl           db 10
nl_len       equ 1

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
    ; RSI -> zero-terminated string
    push rdi
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
    pop rdi
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
    lea rsi, [rel hdr]
    mov edx, hdr_len
    write_stdout

    lea rsi, [rel line1]
    call print_cstr
    mov rax, BUF_SZ
    call print_hex64

    lea rsi, [rel line2]
    call print_cstr
    mov rax, BUF_MASK
    call print_hex64

    lea rsi, [rel line3]
    call print_cstr
    mov rax, ITER
    call print_hex64

    lea rsi, [rel line4]
    call print_cstr
    ; MODE_TEXT is a textual macro; emit it into data and print it
    lea rsi, [rel mode_str]
    call print_cstr
    lea rsi, [rel nl]
    mov edx, nl_len
    write_stdout

    xor edi, edi
    exit

section .data
mode_str db MODE_TEXT, 0

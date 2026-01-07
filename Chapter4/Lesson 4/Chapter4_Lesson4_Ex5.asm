; Chapter4_Lesson4_Ex5.asm
; Using ROL/ROR as bit permutations in a simple 32-bit mixing function.
; This is a pedagogical example (not a cryptographic primitive).
; NASM x86-64, Linux (ELF64), no libc.

BITS 64
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
hex_tbl db "0123456789ABCDEF"
msg1 db "x (input)  = 0x",0
msg2 db "mix(x)     = 0x",0
msg3 db "Note: rotates are common in hash mixing and some ARX-style designs.",10,0

section .bss
buf times 18 db 0

section .text

print_cstr:
    push rax
    push rdi
    push rdx
    mov rdi, rsi
.len:
    cmp byte [rdi], 0
    je .go
    inc rdi
    jmp .len
.go:
    mov rdx, rdi
    sub rdx, rsi
    mov rax, SYS_write
    mov rdi, STDOUT
    syscall
    pop rdx
    pop rdi
    pop rax
    ret

print_hex64:
    push rax
    push rbx
    push rcx
    push rdx
    push r8
    lea r8,  [rel hex_tbl]
    lea rdx, [rel buf]
    mov rcx, 16
.loop:
    rol rax, 4
    mov bl, al
    and bl, 0x0F
    mov bl, [r8 + rbx]
    mov [rdx], bl
    inc rdx
    loop .loop
    mov byte [rdx], 10
    mov rax, SYS_write
    mov rdi, STDOUT
    lea rsi, [rel buf]
    mov rdx, 17
    syscall
    pop r8
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

print_hex32:
    movzx rax, eax
    call print_hex64
    ret

; mix32:
;   EAX = x
; returns:
;   EAX = mixed
mix32:
    rol eax, 7
    xor eax, 0x9E3779B9
    ror eax, 3
    add eax, 0x7F4A7C15
    rol eax, 11
    xor eax, 0xC2B2AE35
    ror eax, 5
    ret

_start:
    mov eax, 0x12345678

    lea rsi, [rel msg1]
    call print_cstr
    call print_hex32

    call mix32

    lea rsi, [rel msg2]
    call print_cstr
    call print_hex32

    lea rsi, [rel msg3]
    call print_cstr

    mov rax, SYS_exit
    xor rdi, rdi
    syscall

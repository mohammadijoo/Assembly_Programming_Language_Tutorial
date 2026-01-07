; Chapter4_Lesson4_Ex10.asm
; Exercise (Hard): Rotate-based 32-bit hash over a byte string.
; hash = 0; for each byte b: hash = ROL(hash, 5) XOR b; then add length and finalize with rotates.
; Demonstrates a practical loop where ROL is used as a cheap "mixing permutation".
; NASM x86-64, Linux (ELF64), no libc.

BITS 64
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
hex_tbl db "0123456789ABCDEF"
s db "ShiftRotateLesson4",0
msg1 db "hash(s) = 0x",0

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

hash32_rol:
    xor eax, eax          ; hash
    xor ecx, ecx          ; length
    lea rsi, [rel s]
.loop:
    mov bl, [rsi]
    cmp bl, 0
    je .done
    rol eax, 5
    xor al, bl            ; XOR into low byte (cheap)
    inc rsi
    inc ecx
    jmp .loop
.done:
    add eax, ecx          ; incorporate length
    rol eax, 13
    xor eax, 0x9E3779B9
    ror eax, 7
    ret

_start:
    call hash32_rol
    lea rsi, [rel msg1]
    call print_cstr
    movzx rax, eax
    call print_hex64

    mov rax, SYS_exit
    xor rdi, rdi
    syscall

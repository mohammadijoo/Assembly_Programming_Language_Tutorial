; Chapter4_Lesson4_Ex1.asm
; Demonstration of SHL/SHR and carry-out (CF) on an 8-bit value.
; NASM x86-64, Linux (ELF64), no libc.

BITS 64
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
hex_tbl db "0123456789ABCDEF"
msg1 db "Original byte: 0x",0
msg2 db "After SHL 1   : 0x",0
msg3 db "CF after SHL 1: ",0
msg4 db "After SHR 3   : 0x",0
msg5 db "CF after SHR 3: ",0
nl   db 10,0

section .bss
buf db 0,0,0,0   ; enough for "XY\n\0"

section .text

; write C-string at RSI
print_cstr:
    push rax
    push rdi
    push rdx
    mov rdi, rsi
    xor rax, rax
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

; print AL as two hex digits + newline
print_hex8:
    push rax
    push rbx
    push rcx
    push rdx
    lea rbx, [rel hex_tbl]
    lea rcx, [rel buf]

    mov dl, al
    shr dl, 4
    mov dl, [rbx + rdx]
    mov [rcx], dl

    mov dl, al
    and dl, 0x0F
    mov dl, [rbx + rdx]
    mov [rcx+1], dl

    mov byte [rcx+2], 10
    mov rax, SYS_write
    mov rdi, STDOUT
    mov rsi, rcx
    mov rdx, 3
    syscall

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; print 0/1 in AL + newline
print_bit:
    push rax
    push rdx
    mov dl, al
    add dl, '0'
    mov [rel buf], dl
    mov byte [rel buf+1], 10
    mov rax, SYS_write
    mov rdi, STDOUT
    lea rsi, [rel buf]
    mov rdx, 2
    syscall
    pop rdx
    pop rax
    ret

_start:
    mov al, 0b10110001

    lea rsi, [rel msg1]
    call print_cstr
    call print_hex8

    ; SHL 1
    shl al, 1
    setc bl
    lea rsi, [rel msg2]
    call print_cstr
    call print_hex8

    lea rsi, [rel msg3]
    call print_cstr
    mov al, bl
    call print_bit

    ; Restore original then SHR 3
    mov al, 0b10110001
    shr al, 3
    setc bl

    lea rsi, [rel msg4]
    call print_cstr
    call print_hex8

    lea rsi, [rel msg5]
    call print_cstr
    mov al, bl
    call print_bit

    mov rax, SYS_exit
    xor rdi, rdi
    syscall

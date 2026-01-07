; Chapter4_Lesson4_Ex2.asm
; Flags behavior for SHL/SHR with count = 0, 1, and >1 (pushfq/pop).
; NASM x86-64, Linux (ELF64), no libc.

BITS 64
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
hex_tbl db "0123456789ABCDEF"
msg0 db "RFLAGS (hex): 0x",0
msgA db "Count=0 (no-op), x=0x",0
msgB db "Count=1,       x=0x",0
msgC db "Count=4,       x=0x",0
msgD db "After SHR 1,   x=0x",0

section .bss
buf times 18 db 0   ; 16 hex + '\n' + 0

section .text

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

; print RAX as 16 hex digits + newline using ROL-by-4 nibble rotation
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

print_flags:
    push rax
    push rsi
    lea rsi, [rel msg0]
    call print_cstr
    pop rsi
    pop rax
    pushfq
    pop rax
    call print_hex64
    ret

_start:
    mov eax, 0x80000011    ; chosen to make MSB/LSB effects visible

    ; Count=0: should not change flags or value
    lea rsi, [rel msgA]
    call print_cstr
    mov eax, 0x80000011
    shl eax, 0
    movzx rax, eax
    call print_hex64
    call print_flags

    ; Count=1: OF has a defined meaning; CF captures bit shifted out
    lea rsi, [rel msgB]
    call print_cstr
    mov eax, 0x80000011
    shl eax, 1
    movzx rax, eax
    call print_hex64
    call print_flags

    ; Count=4: OF is architecturally undefined; CF is last bit shifted out
    lea rsi, [rel msgC]
    call print_cstr
    mov eax, 0x80000011
    shl eax, 4
    movzx rax, eax
    call print_hex64
    call print_flags

    ; SHR 1: OF defined as original MSB (for count=1)
    lea rsi, [rel msgD]
    call print_cstr
    mov eax, 0x80000011
    shr eax, 1
    movzx rax, eax
    call print_hex64
    call print_flags

    mov rax, SYS_exit
    xor rdi, rdi
    syscall

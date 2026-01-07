; Chapter4_Lesson4_Ex11.asm
; Exercise (Very Hard): 32-bit bit-reversal using only shifts, masks, and OR.
; This is a classic parallel bit permutation (SWAR) implemented with SHL/SHR.
; NASM x86-64, Linux (ELF64), no libc.

BITS 64
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
hex_tbl db "0123456789ABCDEF"
msg0 db "x          = 0x",0
msg1 db "bitrev(x)  = 0x",0

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

bitrev32:
    ; EAX = x
    mov edx, eax
    shr edx, 1
    and edx, 0x55555555
    and eax, 0x55555555
    shl eax, 1
    or  eax, edx

    mov edx, eax
    shr edx, 2
    and edx, 0x33333333
    and eax, 0x33333333
    shl eax, 2
    or  eax, edx

    mov edx, eax
    shr edx, 4
    and edx, 0x0F0F0F0F
    and eax, 0x0F0F0F0F
    shl eax, 4
    or  eax, edx

    ; byte swap with shifts
    mov edx, eax
    shr edx, 24
    mov ecx, eax
    shr ecx, 8
    and ecx, 0x0000FF00
    or  edx, ecx
    mov ecx, eax
    shl ecx, 8
    and ecx, 0x00FF0000
    or  edx, ecx
    shl eax, 24
    or  eax, edx
    ret

_start:
    mov eax, 0x01234567
    lea rsi, [rel msg0]
    call print_cstr
    mov eax, 0x01234567
    call print_hex32

    mov eax, 0x01234567
    call bitrev32
    lea rsi, [rel msg1]
    call print_cstr
    call print_hex32

    mov rax, SYS_exit
    xor rdi, rdi
    syscall

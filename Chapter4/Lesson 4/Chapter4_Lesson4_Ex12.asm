; Chapter4_Lesson4_Ex12.asm
; Exercise (Very Hard): Count Leading Zeros (CLZ) for 32-bit integers using only shifts and compares.
; This avoids BSR/LZCNT to keep focus on shift-based reasoning.
; For x==0, returns 32.
; NASM x86-64, Linux (ELF64), no libc.

BITS 64
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
hex_tbl db "0123456789ABCDEF"
msg0 db "x      = 0x",0
msg1 db "clz(x) = 0x",0

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

; clz32:
;   EAX = x
; returns:
;   EAX = number of leading zeros (0..32)
clz32:
    test eax, eax
    jnz .nz
    mov eax, 32
    ret
.nz:
    xor edx, edx       ; n = 0
    cmp eax, 0x0000FFFF
    ja  .step8
    add edx, 16
    shl eax, 16
.step8:
    cmp eax, 0x00FFFFFF
    ja  .step4
    add edx, 8
    shl eax, 8
.step4:
    cmp eax, 0x0FFFFFFF
    ja  .step2
    add edx, 4
    shl eax, 4
.step2:
    cmp eax, 0x3FFFFFFF
    ja  .step1
    add edx, 2
    shl eax, 2
.step1:
    cmp eax, 0x7FFFFFFF
    ja  .done
    add edx, 1
.done:
    mov eax, edx
    ret

_start:
    mov eax, 0x00100000

    lea rsi, [rel msg0]
    call print_cstr
    mov eax, 0x00100000
    call print_hex32

    mov eax, 0x00100000
    call clz32

    lea rsi, [rel msg1]
    call print_cstr
    call print_hex32

    mov rax, SYS_exit
    xor rdi, rdi
    syscall

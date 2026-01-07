; Chapter4_Lesson4_Ex4.asm
; Variable bitfield extraction using shift-left then shift-right "compress" (no AND mask needed).
; field = (x >> start) & ((1<<len)-1)
; implemented as: tmp = x >> start; tmp <<= (32-len); tmp >>= (32-len)
; NASM x86-64, Linux (ELF64), no libc.

BITS 64
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
hex_tbl db "0123456789ABCDEF"
msg1 db "x              = 0x",0
msg2 db "start (bits)    = 0x",0
msg3 db "len (bits)      = 0x",0
msg4 db "extracted field = 0x",0

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

; extract_bits32:
;   EDI = x (32-bit)
;   ESI = start (0..31)
;   EDX = len (1..32)
; returns:
;   EAX = field (right-aligned)
extract_bits32:
    push rcx
    mov eax, edi
    mov ecx, esi
    and ecx, 31
    mov cl, cl
    shr eax, cl

    mov ecx, 32
    sub ecx, edx        ; ecx = 32 - len
    and ecx, 31
    mov cl, cl
    shl eax, cl
    shr eax, cl
    pop rcx
    ret

_start:
    mov edi, 0xDEADBEEF
    mov esi, 9          ; start bit
    mov edx, 7          ; len

    lea rsi, [rel msg1]
    call print_cstr
    mov eax, edi
    movzx rax, eax
    call print_hex64

    lea rsi, [rel msg2]
    call print_cstr
    movzx rax, esi
    call print_hex64

    lea rsi, [rel msg3]
    call print_cstr
    movzx rax, edx
    call print_hex64

    call extract_bits32

    lea rsi, [rel msg4]
    call print_cstr
    movzx rax, eax
    call print_hex64

    mov rax, SYS_exit
    xor rdi, rdi
    syscall

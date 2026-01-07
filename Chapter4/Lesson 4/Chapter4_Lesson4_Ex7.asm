; Chapter4_Lesson4_Ex7.asm
; NASM preprocessor "header-style" macros for shifts/rotates, plus a small test.
; You can rename this file to .inc and include it from other modules via:
;   %include "Chapter4_Lesson4_Ex7.asm"

BITS 64
global _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

section .data
hex_tbl db "0123456789ABCDEF"
msg1 db "ROTL32 macro result = 0x",0
msg2 db "ROTR64 macro result = 0x",0

section .bss
buf times 18 db 0

; ----------------------------
; "Header" macros
; ----------------------------
%macro ROTL32 2
    ; ROTL32 dst32, count
    ; count is masked to 0..31 to make behavior explicit across callers.
    mov ecx, %2
    and ecx, 31
    rol %1, cl
%endmacro

%macro ROTR64 2
    ; ROTR64 dst64, count
    mov ecx, %2
    and ecx, 63
    ror %1, cl
%endmacro

%macro SHL_U64 2
    ; SHL_U64 dst64, count  (logical left shift)
    mov ecx, %2
    and ecx, 63
    shl %1, cl
%endmacro

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

_start:
    mov eax, 0xA1B2C3D4
    ROTL32 eax, 9
    lea rsi, [rel msg1]
    call print_cstr
    movzx rax, eax
    call print_hex64

    mov rax, 0x0123456789ABCDEF
    ROTR64 rax, 13
    lea rsi, [rel msg2]
    call print_cstr
    call print_hex64

    mov rax, SYS_exit
    xor rdi, rdi
    syscall

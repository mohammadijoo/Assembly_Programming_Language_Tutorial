; Chapter3_Lesson10_Ex6.asm
; NASM macro "header-style" utilities for bitfield extract/insert.
; In real projects you would typically store these in a .inc file and %include it.
; Assemble: nasm -felf64 Chapter3_Lesson10_Ex6.asm && ld -o ex6 Chapter3_Lesson10_Ex6.o
; Run:      ./ex6

BITS 64
GLOBAL _start

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

;------------------------------------------------------------
; BF_EXTRACT dst, src, lsb, width
; Requirements:
; - lsb and width are immediate constants
; - width must be in 1..63 for this simple macro (see Lesson text for width=64 handling)
;------------------------------------------------------------
%macro BF_EXTRACT 4
    ; dst <- (src >> lsb) & ((1<<width)-1)
    mov %1, %2
    shr %1, %3
    and %1, ((1 << %4) - 1)
%endmacro

;------------------------------------------------------------
; BF_INSERT dst, value, lsb, width
; Requirements:
; - lsb and width are immediate constants
; - width must be in 1..63 (macro uses (1<<width))
; Semantics:
; - dst = (dst & ~mask) | ((value & ((1<<width)-1)) << lsb)
;------------------------------------------------------------
%macro BF_INSERT 4
    ; clear field in dst
    and %1, ~(((1 << %4) - 1) << %3)
    ; insert masked value
    mov r11, %2
    and r11, ((1 << %4) - 1)
    shl r11, %3
    or  %1, r11
%endmacro

SECTION .rodata
msg_before: db "before = ",0
msg_after:  db "after  = ",0
msg_get:    db "get(len) = ",0
hexdigits:  db "0123456789ABCDEF"

SECTION .bss
hexbuf: resb 19

SECTION .text

write_buf:
    mov rax, SYS_write
    mov rdi, STDOUT
    syscall
    ret

print_cstr:
    xor rdx, rdx
.count:
    cmp byte [rsi+rdx], 0
    je .go
    inc rdx
    jmp .count
.go:
    jmp write_buf

print_hex64:
    lea rsi, [rel hexbuf]
    mov byte [rsi+0], '0'
    mov byte [rsi+1], 'x'
    mov rax, rdi
    lea rbx, [rel hexdigits]
    mov rcx, 16
.loop:
    mov rdx, rax
    and rdx, 0xF
    mov dl, [rbx+rdx]
    mov [rsi+1+rcx], dl
    shr rax, 4
    dec rcx
    jnz .loop
    mov byte [rsi+18], 10
    mov rdx, 19
    jmp write_buf

_start:
    ; Use the same 32-bit packed header as Ex1/Ex2 (in EAX).
    mov eax, 0xA5C3E21B
    mov edi, rax

    lea rsi, [rel msg_before]
    call print_cstr
    call print_hex64

    ; Read length field (12 bits at lsb=12) into EBX
    BF_EXTRACT ebx, eax, 12, 12
    lea rsi, [rel msg_get]
    call print_cstr
    mov edi, rbx
    call print_hex64

    ; Update type field to 0x7E (8 bits at lsb=4)
    BF_INSERT eax, 0x7E, 4, 8

    ; Update version to 0x9 (4 bits at lsb=0)
    BF_INSERT eax, 0x9, 0, 4

    mov edi, rax
    lea rsi, [rel msg_after]
    call print_cstr
    call print_hex64

    xor edi, edi
    mov eax, SYS_exit
    syscall

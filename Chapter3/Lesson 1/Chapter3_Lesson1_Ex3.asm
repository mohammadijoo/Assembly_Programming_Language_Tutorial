; Chapter3_Lesson1_Ex3.asm
; Lesson goal: Observe contiguous byte layout by dumping bytes from .data.
; Build:
;   nasm -felf64 Chapter3_Lesson1_Ex3.asm -o ex3.o
;   ld ex3.o -o ex3
; Run:
;   ./ex3

%include "Chapter3_Lesson1_Ex1.asm"
default rel

section .rodata
title db "Hexdump of a packed data block (byte-addressed memory):", 10, 0
hex_digits db "0123456789abcdef"

section .data
align 1
blob:
    db 0x48, 0x65, 0x6c, 0x6c, 0x6f        ; "Hello"
    db 0x00
    dw 0x1234                               ; little-endian 34 12
    dd 0x90abcdef                           ; little-endian ef cd ab 90
    dq 0x1122334455667788                   ; little-endian 88 77 ... 11
blob_end:

section .text
global _start

; Print RCX bytes starting at RSI, as "xx " hex tokens plus newline each 16 bytes.
; Clobbers: RAX,RBX,RCX,RDX,RSI,RDI,R8-R11
hexdump:
    push rbx
    xor rbx, rbx                ; index
.loop:
    cmp rbx, rcx
    jae .done

    ; Convert one byte to two hex chars in a small stack buffer.
    mov al, [rsi + rbx]
    mov r8b, al                 ; keep original

    sub rsp, 8
    lea rdi, [rsp]
    ; high nibble
    mov al, r8b
    shr al, 4
    and al, 0x0F
    movzx rax, al
    mov al, [hex_digits + rax]
    mov [rdi + 0], al
    ; low nibble
    mov al, r8b
    and al, 0x0F
    movzx rax, al
    mov al, [hex_digits + rax]
    mov [rdi + 1], al
    mov byte [rdi + 2], ' '
    sys_write FD_STDOUT, rdi, 3
    add rsp, 8

    inc rbx

    ; Newline every 16 bytes
    test bl, 0x0F
    jnz .loop
    sub rsp, 8
    mov byte [rsp], 10
    sys_write FD_STDOUT, rsp, 1
    add rsp, 8
    jmp .loop

.done:
    ; Final newline if last line not aligned
    test bl, 0x0F
    jz .ret
    sub rsp, 8
    mov byte [rsp], 10
    sys_write FD_STDOUT, rsp, 1
    add rsp, 8
.ret:
    pop rbx
    ret

_start:
    lea rdi, [title]
    call write_z

    lea rsi, [blob]
    mov rcx, blob_end - blob
    call hexdump

    sys_exit 0

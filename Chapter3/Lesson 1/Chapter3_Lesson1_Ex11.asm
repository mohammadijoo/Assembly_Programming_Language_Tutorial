; Chapter3_Lesson1_Ex11.asm
; Programming Exercise 2 (solution):
; Implement memmove(dst, src, n) that works with overlap.
; Then demonstrate by shifting bytes inside a buffer.
; Build:
;   nasm -felf64 Chapter3_Lesson1_Ex11.asm -o ex11.o
;   ld ex11.o -o ex11
; Run:
;   ./ex11

%include "Chapter3_Lesson1_Ex1.asm"
default rel

section .rodata
hex_digits db "0123456789abcdef"
intro db "Exercise 2 solution: memmove overlap-safe", 10, 0
m_before db "Before memmove:", 10, 0
m_after  db "After memmove (dst=buf+4, src=buf, n=16):", 10, 0

section .data
align 1
buf db 0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07
    db 0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F
    db 0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17
buf_end:

section .text
global _start

; minimal hex dump of 24 bytes as "xx " tokens + newline (for visualization)
dump24:
    push rbx
    xor rbx, rbx
.loop:
    cmp rbx, 24
    jae .done
    mov al, [rsi + rbx]
    mov r8b, al

    sub rsp, 8
    lea rdi, [rsp]
    mov al, r8b
    shr al, 4
    and al, 0x0F
    movzx rax, al
    mov al, [hex_digits + rax]
    mov [rdi + 0], al
    mov al, r8b
    and al, 0x0F
    movzx rax, al
    mov al, [hex_digits + rax]
    mov [rdi + 1], al
    mov byte [rdi + 2], ' '
    sys_write FD_STDOUT, rdi, 3
    add rsp, 8

    inc rbx
    jmp .loop
.done:
    sub rsp, 8
    mov byte [rsp], 10
    sys_write FD_STDOUT, rsp, 1
    add rsp, 8
    pop rbx
    ret

; memmove:
;   RDI = dst, RSI = src, RDX = n
; Works for overlap by choosing direction.
; Returns RAX = dst
memmove:
    mov rax, rdi
    test rdx, rdx
    jz .ret

    ; if dst &lt; src or dst &gt;= src+n => forward copy is safe
    mov rcx, rsi
    add rcx, rdx              ; rcx = src + n
    cmp rdi, rsi
    jb .forward
    cmp rdi, rcx
    jae .forward

    ; backward copy for overlap where dst in (src, src+n)
    std
    lea rsi, [rsi + rdx - 1]
    lea rdi, [rdi + rdx - 1]
    mov rcx, rdx
    rep movsb
    cld
    jmp .ret

.forward:
    cld
    mov rcx, rdx
    rep movsb
.ret:
    ret

_start:
    lea rdi, [intro]
    call write_z

    lea rdi, [m_before]
    call write_z
    lea rsi, [buf]
    call dump24

    ; Overlapping move: shift first 16 bytes right by 4
    lea rdi, [buf + 4]        ; dst
    lea rsi, [buf]            ; src
    mov rdx, 16               ; n
    call memmove

    lea rdi, [m_after]
    call write_z
    lea rsi, [buf]
    call dump24

    sys_exit 0

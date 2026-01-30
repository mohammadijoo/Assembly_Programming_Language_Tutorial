; Chapter7_Lesson8_Ex7.asm
; Page alignment helpers: align an address down to the nearest 4KiB boundary and print in hex.
; NASM, Linux x86-64 (ELF64)

%include "Chapter7_Lesson8_Ex9.asm"

default rel
global _start

%define PAGESZ 4096

section .data
msg_a: db "Raw address: 0x"
len_a: equ $-msg_a
msg_b: db "Aligned down: 0x"
len_b: equ $-msg_b
nl: db 10

hex_digits: db "0123456789abcdef"

section .bss
hexbuf: resb 16

section .text
_start:
    and rsp, -16

    ; Choose an address to demonstrate: current stack pointer
    mov rax, rsp
    mov r13, rax

    syscall3 SYS_write, 1, msg_a, len_a
    mov rax, r13
    call u64_to_hex16
    syscall3 SYS_write, 1, hexbuf, 16
    syscall3 SYS_write, 1, nl, 1

    ; align_down = floor(addr / 4096) * 4096
    mov rax, r13
    shr rax, 12
    shl rax, 12
    mov r14, rax

    syscall3 SYS_write, 1, msg_b, len_b
    mov rax, r14
    call u64_to_hex16
    syscall3 SYS_write, 1, hexbuf, 16
    syscall3 SYS_write, 1, nl, 1

    syscall1 SYS_exit, 0

; u64_to_hex16: converts rax to 16 hex chars into hexbuf
u64_to_hex16:
    push rbx
    push rcx
    push rdx

    lea rbx, [rel hex_digits]
    lea rcx, [rel hexbuf]
    mov rdx, 16
.hex_loop:
    mov r8, rax
    shr r8, 60
    and r8, 0xF
    mov r9b, [rbx + r8]
    mov [rcx], r9b
    inc rcx
    shl rax, 4
    dec rdx
    jnz .hex_loop

    pop rdx
    pop rcx
    pop rbx
    ret

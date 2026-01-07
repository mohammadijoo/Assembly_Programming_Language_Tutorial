; Chapter 4 - Lesson 11 (Example 8)
; Minimal Linux x86-64 syscall helpers + a tiny hex printer.
; NASM syntax. Intended to be included by other examples via:
;   %include "Chapter4_Lesson11_Ex8.asm"

%ifndef CH4_L11_MINI_IO_INCLUDED
%define CH4_L11_MINI_IO_INCLUDED 1

bits 64
default rel

%macro WRITE 2
    ; WRITE buf, len  -> write(1, buf, len)
    mov eax, 1
    mov edi, 1
    mov rsi, %1
    mov edx, %2
    syscall
%endmacro

%macro EXIT 1
    ; EXIT code -> exit(code)
    mov eax, 60
    mov edi, %1
    syscall
%endmacro

section .text

; ------------------------------------------------------------
; print_hex_u64
;   Input : RDI = unsigned 64-bit value
;   Output: prints "0x" + 16 hex digits + "\n" to stdout
;   Clobbers: RAX, RCX, RDX, RSI, R8
; ------------------------------------------------------------
print_hex_u64:
    push rbp
    mov rbp, rsp

    lea rsi, [rel __hexbuf]
    mov byte [rsi + 0], '0'
    mov byte [rsi + 1], 'x'

    lea r8,  [rel __hexdigits]
    mov rax, rdi
    lea rsi, [rel __hexbuf + 2]

    mov ecx, 16
.hex_loop:
    mov rdx, rax
    shr rdx, 60
    and edx, 0xF
    mov dl, [r8 + rdx]
    mov [rsi], dl
    inc rsi
    shl rax, 4
    loop .hex_loop

    mov byte [rel __hexbuf + 18], 10

    ; write(1, __hexbuf, 19)
    mov eax, 1
    mov edi, 1
    lea rsi, [rel __hexbuf]
    mov edx, 19
    syscall

    pop rbp
    ret

section .rodata
__hexdigits db "0123456789ABCDEF"

section .bss
__hexbuf resb 19

%endif

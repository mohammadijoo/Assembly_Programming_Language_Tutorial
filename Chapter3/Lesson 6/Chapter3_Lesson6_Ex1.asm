BITS 64
default rel

; Chapter 3 — Lesson 6 Support Include (NASM, Linux x86-64)
; --------------------------------------------------------
; This file is intended to be included with:
;   %include "Chapter3_Lesson6_Ex1.asm"
;
; It provides small syscall macros and a debug printer for hex values.
;
; Exported utilities:
;   WRITE  <buf>, <len>    ; write buffer to stdout (fd=1)
;   EXIT   <code>          ; exit process with status code
;   write_hex64            ; prints RAX as 0xXXXXXXXXXXXXXXXX\n
;
; Notes:
; - The macros clobber RAX, RDI, RSI, RDX (syscall ABI).
; - write_hex64 clobbers RBX, RCX, RDX, RSI, RDI, R8 and preserves them via pushes.
; - This is a minimal teaching aid, not a full I/O library.

%ifndef CH3_L6_SUPPORT_GUARD
%define CH3_L6_SUPPORT_GUARD 1

%define SYS_write 1
%define SYS_exit  60
%define FD_STDOUT 1

%macro WRITE 2
    mov eax, SYS_write
    mov edi, FD_STDOUT
    mov rsi, %1
    mov edx, %2
    syscall
%endmacro

%macro EXIT 1
    mov eax, SYS_exit
    mov edi, %1
    syscall
%endmacro

; --------------------------------------------------------
; write_hex64
; In : RAX = value
; Out: prints "0x" + 16 hex digits + "\n" to stdout
; --------------------------------------------------------
write_hex64:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8

    lea rdi, [rel __hex_buf]
    mov byte [rdi+0], '0'
    mov byte [rdi+1], 'x'

    mov rcx, 16
    lea r8,  [rel __hex_digits]
    lea rbx, [rdi+2+15]          ; last hex digit position

.hex_loop:
    mov rdx, rax
    and rdx, 0xF
    mov dl, [r8+rdx]
    mov [rbx], dl
    shr rax, 4
    dec rbx
    dec rcx
    jnz .hex_loop

    mov byte [rdi+18], 10        ; '\n'
    WRITE rdi, 19

    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

section .rodata
__hex_digits: db "0123456789ABCDEF"

section .bss
__hex_buf: resb 19

section .text
%endif

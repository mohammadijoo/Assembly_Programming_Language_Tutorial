; Chapter7_Lesson7_Ex9.asm
; NASM "header-like" patterns using %define / %macro.
; In a real project, you'd often factor these into .inc files and %include them,
; but we keep everything in one .asm to match the exercise packaging requirement.

%define SYS_exit  60
%define SYS_write  1

; Round an integer up to a multiple of 16:
;   out = 16 * floor((x + 15) / 16)
%macro ALIGN16 2
    ; %1 = input reg, %2 = output reg
    mov     %2, %1
    add     %2, 15
    and     %2, -16
%endmacro

%macro WRITE_STDOUT 2
    ; %1 = ptr, %2 = len
    mov     rdi, 1
    mov     rsi, %1
    mov     rdx, %2
    mov     eax, SYS_write
    syscall
%endmacro

global _start

section .rodata
msg: db "macros ok", 10
msg_len: equ $-msg

section .text
_start:
    ; Example: align a size and exit with (aligned_size & 255)
    mov     rax, 37
    ALIGN16  rax, rbx               ; rbx = 48

    WRITE_STDOUT msg, msg_len

    mov     rdi, rbx
    and     rdi, 255
    mov     eax, SYS_exit
    syscall

; Chapter 3 - Lesson 2 (Example 8)
; Include file (macro "library") for Linux x86-64 syscalls in NASM
;
; Intended usage:
;   %include "Chapter3_Lesson2_Ex8.asm"
;   WRITE msg, msg_len
;   EXIT  0

%ifndef CH3_L2_SYSCALL_INC
%define CH3_L2_SYSCALL_INC 1

%define SYS_write   1
%define SYS_exit    60
%define STDOUT      1

%macro WRITE 2
    mov     eax, SYS_write
    mov     edi, STDOUT
    lea     rsi, [%1]
    mov     edx, %2
    syscall
%endmacro

%macro EXIT 1
    mov     eax, SYS_exit
    mov     edi, %1
    syscall
%endmacro

%endif

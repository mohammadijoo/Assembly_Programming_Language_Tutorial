; Chapter 3 - Lesson 4 (Working with Constants)
; Example 9: Reusable "header" of constants and macros for NASM (%include)
;
; Usage:
;   %include "Chapter3_Lesson4_Ex9.asm"
;
; This file intentionally has no _start. It is meant to be included.

%ifndef CH3_L4_CONSTANTS_INC
%define CH3_L4_CONSTANTS_INC 1

; ------------------------------
; Linux x86-64 syscall constants
; ------------------------------
SYS_read     equ 0
SYS_write    equ 1
SYS_exit     equ 60

FD_STDIN     equ 0
FD_STDOUT    equ 1
FD_STDERR    equ 2

; ------------------------------
; Common ASCII constants
; ------------------------------
ASCII_NL      equ 10
ASCII_CR      equ 13
ASCII_SPACE   equ 32
ASCII_0       equ 48
ASCII_9       equ 57
ASCII_A       equ 65
ASCII_F       equ 70
ASCII_a       equ 97
ASCII_f       equ 102

; ------------------------------
; A disciplined compile-time assertion facility
; ------------------------------
%macro STATIC_ASSERT 2
    %if not (%1)
        %error %2
    %endif
%endmacro

; ------------------------------
; Syscall wrappers (macros)
;   write(fd, buf, len)
;   exit(code)
; ------------------------------
%macro sys_write 3
    mov eax, SYS_write
    mov edi, %1
    mov rsi, %2
    mov edx, %3
    syscall
%endmacro

%macro sys_exit 1
    mov eax, SYS_exit
    mov edi, %1
    syscall
%endmacro

%endif  ; CH3_L4_CONSTANTS_INC

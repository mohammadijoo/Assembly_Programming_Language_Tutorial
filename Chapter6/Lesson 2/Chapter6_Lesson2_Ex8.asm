; Chapter 6 - Lesson 2 - Example 8
; File: Chapter6_Lesson2_Ex8.asm
; Topic: A small "procedure header" (macros + conventions) reusable via %include
;
; Use from another file:
;   %include "Chapter6_Lesson2_Ex8.asm"
;
; Notes:
; - NASM does not have PROC/ENDP keywords by default; macros can emulate them.
; - This file is safe to include multiple times due to %ifndef guards.

%ifndef CH6_L2_PROC_HDR
%define CH6_L2_PROC_HDR 1

default rel

; -------------------------
; Syscall numbers (Linux x86-64)
%define SYS_write 1
%define SYS_exit  60

; -------------------------
; Macro: SYS_EXIT status
%macro SYS_EXIT 1
    mov eax, SYS_exit
    mov edi, %1
    syscall
%endmacro

; Macro: SYS_WRITE fd, buf, len
%macro SYS_WRITE 3
    mov eax, SYS_write
    mov edi, %1
    mov rsi, %2
    mov rdx, %3
    syscall
%endmacro

; -------------------------
; PROC / ENDPROC helpers
; Usage:
;   PROC name, is_global
;     ...
;   ENDPROC
;
; is_global: 1 => emits "global name"
%macro PROC 2
%if %2 = 1
global %1
%endif
%1:
%endmacro

%macro ENDPROC 0
    ret
%endmacro

; -------------------------
; ASSERT_ALIGNED16 label
; Asserts RSP % 16 == 0 at runtime; jumps to label on failure.
; This is a debugging helper; do not keep in hot code.
%macro ASSERT_ALIGNED16 1
    test rsp, 15
    jnz %1
%endmacro

%endif

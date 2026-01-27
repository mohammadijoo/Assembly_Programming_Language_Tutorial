; Chapter6_Lesson1_Ex5.asm
; "Header / library" style macros for procedures (NASM).
; This file is intended to be included with:
;   %include "Chapter6_Lesson1_Ex5.asm"
;
; It defines:
;   PROC_BEGIN name, locals_bytes
;   PROC_END
;   SAVE_GPRS / RESTORE_GPRS (a simple, explicit set)
;
; Notes:
; - These macros do NOT force ABI-correct stack alignment by themselves.
; - You must size locals so the stack stays aligned when needed.

%ifndef PROC_MACROS_GUARD
%define PROC_MACROS_GUARD 1

BITS 64

%macro PROC_BEGIN 2
    global %1
%1:
    push rbp
    mov  rbp, rsp
%if %2 > 0
    sub  rsp, %2
%endif
%endmacro

%macro PROC_END 0
    mov rsp, rbp
    pop rbp
    ret
%endmacro

; Save/restore a conservative set of GPRs often treated as callee-saved (SysV):
; RBX, R12-R15. (RBP is already managed by PROC_BEGIN/END if you use it.)
%macro SAVE_GPRS 0
    push rbx
    push r12
    push r13
    push r14
    push r15
%endmacro

%macro RESTORE_GPRS 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
%endmacro

%endif

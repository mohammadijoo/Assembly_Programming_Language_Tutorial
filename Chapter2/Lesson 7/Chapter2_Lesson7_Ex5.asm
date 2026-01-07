; Chapter 2 - Lesson 7 (Execution Flow) - Example 5
; A "header-like" include file (NASM) for cleaner control-flow examples.
; NOTE: In real projects you would usually name this with .inc,
; but we keep the course naming scheme as requested.
;
; Usage in another file:
;   %include "Chapter2_Lesson7_Ex5.asm"
;   PRINT msg_label, msg_len

%ifndef __CH2_L7_FLOW_UTILS__
%define __CH2_L7_FLOW_UTILS__ 1

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

; PRINT <addr>, <len>
; Clobbers: RAX, RDI, RSI, RDX
%macro PRINT 2
    mov eax, SYS_write
    mov edi, STDOUT
    lea rsi, [%1]
    mov edx, %2
    syscall
%endmacro

; EXIT <status>
; Clobbers: RAX, RDI
%macro EXIT 1
    mov eax, SYS_exit
    mov edi, %1
    syscall
%endmacro

%endif

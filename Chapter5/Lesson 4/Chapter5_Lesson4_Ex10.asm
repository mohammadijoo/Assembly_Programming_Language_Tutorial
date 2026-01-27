; Chapter 5 - Lesson 4 (NASM)
; Example 10: Reusable NASM macros for dense switch dispatch
; Note: This file is meant to be %include'd by other .asm files.
; You may rename it to .inc in your own projects.

%ifndef SWITCH_MACROS_INCLUDED
%define SWITCH_MACROS_INCLUDED 1

; SWITCH_DENSE_DISPATCH reg32, LOW, HIGH, tableLabel, defaultLabel
; - reg32 must contain the switch value (32-bit is typical for C int).
; - LOW/HIGH are integer constants.
; - tableLabel must be a table of 8-byte code pointers (dq labels).
; Dispatch is:
;   idx = reg32 - LOW
;   if idx > (HIGH-LOW) -> default
;   jmp [table + idx*8]
%macro SWITCH_DENSE_DISPATCH 5
    mov eax, %1
    sub eax, %2
    cmp eax, (%3 - %2)
    ja  %5
    lea rbx, [rel %4]
    jmp qword [rbx + rax*8]
%endmacro

; SWITCH_SIGNED_RANGE_DISPATCH reg32, LOW, HIGH, tableLabel, defaultLabel
; For signed comparisons when LOW can be negative and reg32 should be treated signed.
%macro SWITCH_SIGNED_RANGE_DISPATCH 5
    mov eax, %1
    cmp eax, %2
    jl  %5
    cmp eax, %3
    jg  %5
    sub eax, %2
    lea rbx, [rel %4]
    jmp qword [rbx + rax*8]
%endmacro

%endif

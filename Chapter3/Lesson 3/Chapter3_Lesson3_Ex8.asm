; Chapter 3 - Lesson 3 (Ex8)
; A tiny "header-style" module: size constants, struct offsets, and macros.
; This file is meant to be included via:
;   %include "Chapter3_Lesson3_Ex8.asm"
; In a real project you would typically rename it to something like types.inc.
;
; NASM uses bytes as the only true storage unit. These helpers keep intent explicit.

%ifndef TYPES_INC_GUARD
%define TYPES_INC_GUARD 1

%define SIZE_BYTE   1
%define SIZE_WORD   2
%define SIZE_DWORD  4
%define SIZE_QWORD  8

; Macro: DEF_ARRAY name, directive, count, init
; Examples:
;   DEF_ARRAY arr, db, 16, 0
;   DEF_ARRAY wtab, dw, 8, 0x1234
%macro DEF_ARRAY 4
%1: times %3 %2 %4
%endmacro

; Packed record layout (no implicit padding):
;   +0  u8  type
;   +1  u16 len
;   +3  u32 value
;   +7  u64 ts
%define REC_OFF_TYPE   0
%define REC_OFF_LEN    1
%define REC_OFF_VALUE  3
%define REC_OFF_TS     7
%define REC_SIZE       15

; Macro: LOAD_U16 reg32, base, off
%macro LOAD_U16 3
    movzx %1, word [%2 + %3]
%endmacro

; Macro: LOAD_U32 reg32, base, off
%macro LOAD_U32 3
    mov %1, dword [%2 + %3]
%endmacro

; Macro: LOAD_U64 reg64, base, off
%macro LOAD_U64 3
    mov %1, qword [%2 + %3]
%endmacro

%endif

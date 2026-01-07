bits 64
default rel

global _start

; Chapter 3, Lesson 7, Example 8
; NASM assembler-time UTF-8 emission macro for constant code points.
; This is useful for building constant UTF-8 data without manual byte math.

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

; -------------------------------------------------------
; UTF8_CONST cp
; Expands to one or more DB directives for the UTF-8 encoding of cp.
; Constraints:
; - cp must be a constant known at assembly-time.
; - rejects surrogate range and > 0x10FFFF at assembly-time.
; -------------------------------------------------------
%macro UTF8_CONST 1
    %assign __cp %1
    %if (__cp < 0) || (__cp > 0x10FFFF)
        %error Invalid Unicode code point (out of range)
    %endif
    %if (__cp >= 0xD800) && (__cp <= 0xDFFF)
        %error Invalid Unicode code point (surrogate range)
    %endif

    %if __cp <= 0x7F
        db __cp
    %elif __cp <= 0x7FF
        db 0xC0 | (__cp >> 6)
        db 0x80 | (__cp & 0x3F)
    %elif __cp <= 0xFFFF
        db 0xE0 | (__cp >> 12)
        db 0x80 | ((__cp >> 6) & 0x3F)
        db 0x80 | (__cp & 0x3F)
    %else
        db 0xF0 | (__cp >> 18)
        db 0x80 | ((__cp >> 12) & 0x3F)
        db 0x80 | ((__cp >> 6) & 0x3F)
        db 0x80 | (__cp & 0x3F)
    %endif
%endmacro

section .data
    ; Construct a UTF-8 string at assembly time:
    ; "Pi = π, Euro = €, Smile = 😀\n"
    msg:
        db "Pi = "
        UTF8_CONST 0x03C0
        db ", Euro = "
        UTF8_CONST 0x20AC
        db ", Smile = "
        UTF8_CONST 0x1F600
        db 10
    msg_len: equ $ - msg

section .text
_start:
    mov eax, SYS_write
    mov edi, STDOUT
    lea rsi, [msg]
    mov edx, msg_len
    syscall

    xor edi, edi
    mov eax, SYS_exit
    syscall

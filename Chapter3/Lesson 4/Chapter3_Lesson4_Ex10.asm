; Chapter 3 - Lesson 4 (Working with Constants)
; Example 10: Using an include file of constants/macros (%include)

global _start
default rel

%include "Chapter3_Lesson4_Ex9.asm"

; Compile-time sanity checks (fail fast during assembly)
STATIC_ASSERT (ASCII_0 = '0'), "ASCII_0 mismatch"
STATIC_ASSERT ((FD_STDOUT = 1) & (SYS_write = 1)), "Expected Linux syscall/FD values"

section .data
msg  db "Using constants from an include file. Newline is ASCII_NL.", ASCII_NL
msg_len equ $ - msg

section .text
_start:
    sys_write FD_STDOUT, msg, msg_len
    sys_exit 0

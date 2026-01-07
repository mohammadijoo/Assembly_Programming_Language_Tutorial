; Chapter 2 - Lesson 7 (Execution Flow) - Example 9
; Debugging-oriented control flow: INT3 traps and "fail-fast" paths.
; WARNING: Running outside a debugger typically terminates with SIGTRAP.
; Build:
;   nasm -f elf64 Chapter2_Lesson7_Ex9.asm -o ex9.o
;   ld ex9.o -o ex9
; Run under GDB:
;   gdb -q ./ex9
;   (gdb) run

BITS 64
DEFAULT REL

%include "Chapter2_Lesson7_Ex5.asm"

GLOBAL _start

SECTION .data
msg1 db "Before decision", 10
len1 equ $-msg1
msg2 db "Branch taken", 10
len2 equ $-msg2
msg3 db "Branch not taken", 10
len3 equ $-msg3

SECTION .text
_start:
    PRINT msg1, len1
    int3                    ; breakpoint: examine registers/flags here

    mov eax, 7
    cmp eax, 10
    jl  .lt10

.ge10:
    PRINT msg3, len3
    EXIT 0

.lt10:
    PRINT msg2, len2
    int3                    ; breakpoint at a different control-flow location
    EXIT 0

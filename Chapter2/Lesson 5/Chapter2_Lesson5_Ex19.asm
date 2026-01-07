# Chapter 2 - Lesson 5 - Ex19 (AT&T syntax, GAS)
# Demonstrates GAS .macro style and the idea of "header-like" include files.
# In a real project, move the .equ/.macro blocks into a separate file and import it with:
#   .include "asm_common.s"
.equ SYS_write, 1
.equ STDOUT,    1

.macro SYSCALL3 nr, a1, a2, a3
    movq \nr, %rax
    movq \a1, %rdi
    movq \a2, %rsi
    movq \a3, %rdx
    syscall
.endm

.section .rodata
msg:
    .asciz "GAS macro demo: write(1, msg, len)\n"
msg_end:
.equ len, msg_end - msg - 1

.section .text
.globl _start
.type _start, @function

_start:
    SYSCALL3 $SYS_write, $STDOUT, $msg, $len
.Lhang:
    jmp .Lhang

.size _start, .-_start

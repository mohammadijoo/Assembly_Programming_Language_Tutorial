# Chapter 2 - Lesson 5 - Ex10 (AT&T syntax, GAS)
# Demonstrates common GAS directives: .equ, .section, .asciz, .globl, .type, .size.
.equ SYS_write, 1
.equ SYS_exit,  60
.equ STDOUT,    1

.section .rodata
msg:
    .asciz "AT&T syntax: directives demo\n"
msg_end:
.equ msg_len, msg_end - msg - 1

.section .text
.globl _start
.type _start, @function

_start:
    movq $SYS_write, %rax
    movq $STDOUT, %rdi
    leaq msg(%rip), %rsi
    movq $msg_len, %rdx
    syscall

    movq $SYS_exit, %rax
    xorl %edi, %edi
    syscall

.size _start, .-_start

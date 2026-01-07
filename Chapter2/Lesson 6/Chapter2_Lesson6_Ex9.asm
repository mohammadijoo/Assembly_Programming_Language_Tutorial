\
# Chapter2_Lesson6_Ex9.asm
# GAS include file: constants + shared data.

.equ SYS_write, 1
.equ SYS_exit,  60
.equ STDOUT,    1

.section .rodata
msg:
    .ascii "Definitions came from a GAS include file.\n"
msg_end:
.equ msg_len, msg_end - msg

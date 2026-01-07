\
# Chapter2_Lesson6_Ex8.asm
# GAS: using .include to share constants/data between files.
#
# Build:
#   as --64 -g Chapter2_Lesson6_Ex8.asm -o ex8.o
#   ld -o ex8 ex8.o
#   ./ex8

.include "Chapter2_Lesson6_Ex9.asm"

.section .text
.globl _start
.type _start, @function
_start:
    mov $SYS_write, %rax
    mov $STDOUT, %rdi
    lea msg(%rip), %rsi
    mov $msg_len, %rdx
    syscall

    mov $SYS_exit, %rax
    xor %edi, %edi
    syscall
.size _start, . - _start

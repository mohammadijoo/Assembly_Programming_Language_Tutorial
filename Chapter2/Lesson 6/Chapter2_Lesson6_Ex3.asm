\
# Chapter2_Lesson6_Ex3.asm
# GAS (GNU as) + ELF64 + Linux syscalls: write + exit.
#
# Build (Linux):
#   as --64 -g Chapter2_Lesson6_Ex3.asm -o ex3.o
#   ld -o ex3 ex3.o
#   ./ex3
#
# Alternative:
#   gcc -nostdlib -no-pie -Wl,--build-id=none Chapter2_Lesson6_Ex3.asm -o ex3

.section .rodata
msg:
    .ascii "Hello from GAS (ELF64)!\n"
msg_end:
.equ msg_len, msg_end - msg

.section .text
.globl _start
.type _start, @function
_start:
    mov $1, %rax                # SYS_write
    mov $1, %rdi                # fd = 1
    lea msg(%rip), %rsi         # buf
    mov $msg_len, %rdx          # count
    syscall

    mov $60, %rax               # SYS_exit
    xor %edi, %edi
    syscall
.size _start, . - _start

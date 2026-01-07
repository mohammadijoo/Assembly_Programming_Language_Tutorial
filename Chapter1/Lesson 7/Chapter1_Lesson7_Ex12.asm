# hello_gas.s (GAS / AT&T syntax)
# Build:
#   as -o hello_gas.o hello_gas.s
#   ld -o hello_gas hello_gas.o

    .section .data
msg:
    .ascii "Hello from GAS assembly!\n"
msg_end:
    .equ msg_len, msg_end - msg

    .section .text
    .globl _start
_start:
    # write(1, msg, msg_len)
    mov $1, %rax           # SYS_write
    mov $1, %rdi           # fd=1
    lea msg(%rip), %rsi    # buffer
    mov $msg_len, %rdx     # count
    syscall

    # exit(0)
    mov $60, %rax          # SYS_exit
    xor %rdi, %rdi
    syscall

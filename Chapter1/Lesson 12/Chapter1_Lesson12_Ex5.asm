# hello_gas_att.s (Linux x86-64, GAS AT&T syntax)
# Assemble: as --64 hello_gas_att.s -o hello_gas_att.o
# Link:     ld -o hello_gas_att hello_gas_att.o

    .section .rodata
msg:
    .ascii  "Hello from GAS (AT&T)!\n"
msg_end:
    .equ msg_len, msg_end - msg

    .section .text
    .globl _start
_start:
    # write(1, msg, msg_len)
    mov $1, %rax           # SYS_write
    mov $1, %rdi           # fd = stdout
    lea msg(%rip), %rsi    # buffer
    mov $msg_len, %rdx     # length
    syscall

    # exit(0)
    mov $60, %rax          # SYS_exit
    xor %rdi, %rdi
    syscall
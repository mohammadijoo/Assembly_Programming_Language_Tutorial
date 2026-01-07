# src/exit0_gas_att.s
.global _start
.text
_start:
    mov $60, %rax
    xor %rdi, %rdi
    syscall

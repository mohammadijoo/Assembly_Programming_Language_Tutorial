# include/print_macros_gas.inc (GAS)
    .macro WRITE_LIT_GAS buf, len
        mov $SYS_write, %eax
        mov $1, %edi
        mov \buf, %rsi
        mov \len, %edx
        syscall
    .endm

# macros_gas.inc (illustrative)
    .macro SYSV_PROLOGUE
        push %rbp
        mov %rsp, %rbp
    .endm

    .macro SYSV_EPILOGUE
        pop %rbp
        ret
    .endm
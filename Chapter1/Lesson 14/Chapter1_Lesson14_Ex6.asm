; SysV: call printf("x=%ld\n", x)
; Requires: AL = number of XMM regs used for varargs (0 here).
; Also requires: stack alignment invariant maintained at the call boundary.

extern printf
global print_one_sysv
section .rodata
fmt: db "x=%ld", 10, 0

section .text
print_one_sysv:
    ; long print_one_sysv(long x)
    ; x in RDI. We'll call printf(fmt, x). That means:
    ;   RDI = fmt
    ;   RSI = x
    push rbp
    mov rbp, rsp

    ; Align: after push rbp, RSP changed by 8. Ensure 16B alignment before call.
    ; Simple strategy: subtract 8 to re-align, then add it back.
    sub rsp, 8

    mov rsi, rdi            ; second arg = x
    lea rdi, [rel fmt]      ; first arg = fmt
    xor eax, eax            ; AL=0 vector args, also clears RAX
    call printf

    add rsp, 8
    pop rbp
    ret

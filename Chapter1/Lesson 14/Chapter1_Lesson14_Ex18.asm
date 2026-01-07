global call_tramp
section .text
call_tramp:
    ; SysV args:
    ; f in RDI, a in RSI, b in RDX, c in RCX
    ; return in RAX

    test rdi, rdi
    jnz .nonnull
    ud2

.nonnull:
    ; Prologue: preserve callee-saved regs we will use (we'll use RBX as temp)
    push rbp
    mov rbp, rsp
    push rbx

    ; Stack alignment:
    ; Entry: (RSP+8) mod 16 = 0
    ; After push rbp and push rbx (16 bytes), alignment preserved for calls.

    mov rbx, rdi        ; save f in RBX (callee-saved)
    mov rdi, rsi        ; set arg1 = a
    mov rsi, rdx        ; set arg2 = b
    mov rdx, rcx        ; set arg3 = c
    call rbx            ; indirect call

    pop rbx
    pop rbp
    ret

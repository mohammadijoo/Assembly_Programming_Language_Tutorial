global clamp_i64
clamp_i64:
    ; rdi = x, rsi = lo, rdx = hi
    mov     rax, rdi          ; rax = x

    ; if (x < lo) x = lo
    cmp     rax, rsi          ; signed compare
    cmovl   rax, rsi

    ; if (x > hi) x = hi
    cmp     rax, rdx
    cmovg   rax, rdx
    ret

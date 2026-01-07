global memcmp64
memcmp64:
    ; rdi = p1, rsi = p2, rdx = n
    xor     rcx, rcx              ; i = 0
    xor     rax, rax              ; default return = 0

.loop:
    cmp     rcx, rdx
    jae     .done

    mov     al, byte [rdi + rcx]  ; a = p1[i]
    mov     r8b, byte [rsi + rcx] ; b = p2[i]
    cmp     al, r8b
    jne     .diff

    inc     rcx
    jmp     .loop

.diff:
    ; return (unsigned)a - (unsigned)b as signed 64-bit
    movzx   r9, al
    movzx   r10, r8b
    mov     rax, r9
    sub     rax, r10
    ret

.done:
    ret

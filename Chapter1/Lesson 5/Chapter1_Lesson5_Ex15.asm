global strlen64
strlen64:
    ; rdi = char* s
    xor     rax, rax          ; len = 0

.loop:
    mov     dl, byte [rdi + rax]
    test    dl, dl
    jz      .done
    inc     rax
    jmp     .loop

.done:
    ret

; if (x == 0) y = 10; else y = 20;
; rax = x, rbx = y (output)

test    rax, rax
jnz     .else
mov     rbx, 10
jmp     .end

.else:
mov     rbx, 20

.end:

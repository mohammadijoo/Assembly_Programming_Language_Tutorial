; sum = 0; for (i=0; i<n; i++) sum += a[i];
; rdi = a (int64_t*), rsi = n, rax = sum (out)

xor     rax, rax        ; sum = 0
xor     rcx, rcx        ; i = 0

.loop:
cmp     rcx, rsi
jae     .done
add     rax, qword [rdi + rcx*8]
inc     rcx
jmp     .loop

.done:

; Example: explicit register roles for a tight loop
; rdi = base pointer
; rsi = element count
; rcx = index
; rax = accumulator

xor     rax, rax
xor     rcx, rcx

.loop:
cmp     rcx, rsi
jae     .done
add     rax, qword [rdi + rcx*8]
inc     rcx
jmp     .loop

.done:
; rax holds sum

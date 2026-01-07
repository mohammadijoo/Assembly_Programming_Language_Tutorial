; x86-64 SysV:
; int64_t sum_i32(const int32_t* a, size_t n)
; RDI = a, RSI = n
; RAX = sum (signed 64-bit)
global sum_i32_sysv
sum_i32_sysv:
    xor rax, rax            ; sum = 0
    test rsi, rsi
    jz .done

.loop:
    movsxd rdx, dword [rdi] ; load int32 and sign-extend to 64
    add rax, rdx
    add rdi, 4
    dec rsi
    jnz .loop

.done:
    ret

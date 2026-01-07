global sum_i32_checked
sum_i32_checked:
    ; rdi = int32_t* a, rsi = n
    xor     rax, rax          ; sum = 0 (int64)
    xor     rdx, rdx          ; overflow_flag = 0
    xor     rcx, rcx          ; i = 0

.loop:
    cmp     rcx, rsi
    jae     .done

    ; load int32 and sign-extend to 64
    movsxd  r8, dword [rdi + rcx*4]
    add     rax, r8

    ; check if rax is within int32 signed range
    ; range: -2147483648 .. 2147483647
    cmp     rax, 2147483647
    jg      .set_over
    cmp     rax, -2147483648
    jl      .set_over

.next:
    inc     rcx
    jmp     .loop

.set_over:
    mov     rdx, 1
    jmp     .next

.done:
    ret

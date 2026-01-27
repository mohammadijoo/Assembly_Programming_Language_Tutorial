bits 64
default rel
global _start

section .text
_start:
    ; Two implementations of exponentiation by squaring with overflow checks:
    ;   - pow_rec: recursive (log2(exp) depth)
    ;   - pow_iter: iterative bit-scan
    ;
    ; Return convention:
    ;   RAX = result (0 if overflow)
    ;   RDX = status (0 ok, 1 overflow)

    ; Test 1: 3^20 = 3486784401 (fits uint64)
    mov edi, 3
    mov esi, 20
    call pow_rec
    mov rbx, rax              ; save result
    mov r12, rdx              ; save status

    mov edi, 3
    mov esi, 20
    call pow_iter

    cmp rax, rbx
    jne .bad
    cmp rdx, r12
    jne .bad
    cmp rdx, 0
    jne .bad
    mov rcx, 3486784401
    cmp rax, rcx
    jne .bad

    ; Test 2: 10^20 overflows uint64 (2^64 is about 1.84e19)
    mov edi, 10
    mov esi, 20
    call pow_rec
    mov r13, rdx

    mov edi, 10
    mov esi, 20
    call pow_iter

    cmp rdx, r13
    jne .bad
    cmp rdx, 1
    jne .bad

.good:
    xor edi, edi
    mov eax, 60
    syscall

.bad:
    mov edi, 1
    mov eax, 60
    syscall

; pow_rec(base, exp) with overflow detection
pow_rec:
    test rsi, rsi
    jnz .nz
    mov eax, 1
    xor edx, edx
    ret
.nz:
    cmp rsi, 1
    jne .recurse
    mov rax, rdi
    xor edx, edx
    ret

.recurse:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov [rbp-8], rdi          ; base
    mov [rbp-16], rsi         ; exp

    mov rsi, [rbp-16]
    shr rsi, 1                ; exp/2
    mov rdi, [rbp-8]          ; base
    call pow_rec

    test rdx, rdx
    jnz .overflow_return

    mov rcx, rax              ; half = pow(base, exp/2)

    ; square: half * half
    mov rax, rcx
    mul rcx                   ; unsigned mul: RDX:RAX = RAX*RCX
    test rdx, rdx
    jnz .overflow_set
    mov [rbp-24], rax         ; squared

    ; if (exp is odd) multiply by base once more
    mov rsi, [rbp-16]
    test rsi, 1
    jz .even

    mov rax, [rbp-24]
    mov rcx, [rbp-8]
    mul rcx
    test rdx, rdx
    jnz .overflow_set

    xor edx, edx
    leave
    ret

.even:
    mov rax, [rbp-24]
    xor edx, edx
    leave
    ret

.overflow_set:
    mov rax, 0
    mov edx, 1
    leave
    ret

.overflow_return:
    mov rax, 0
    mov edx, 1
    leave
    ret

; pow_iter(base, exp) with overflow detection (bit-scan / exponentiation by squaring)
pow_iter:
    push rbx

    mov rbx, 1                ; result
    mov rcx, rdi              ; base

.loop:
    test rsi, rsi
    jz .done_ok

    test rsi, 1
    jz .skip_res_mul

    mov rax, rbx
    mul rcx
    test rdx, rdx
    jnz .overflow
    mov rbx, rax

.skip_res_mul:
    shr rsi, 1
    test rsi, rsi
    jz .done_ok

    mov rax, rcx
    mul rcx
    test rdx, rdx
    jnz .overflow
    mov rcx, rax
    jmp .loop

.done_ok:
    mov rax, rbx
    xor edx, edx
    pop rbx
    ret

.overflow:
    mov rax, 0
    mov edx, 1
    pop rbx
    ret

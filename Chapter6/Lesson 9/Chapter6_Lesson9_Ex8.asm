; Chapter6_Lesson9_Ex8.asm
; Programming Exercise (Solution):
; Add two 128-bit unsigned integers and return:
;   - sum.low  in RAX
;   - sum.high in RDX
;   - carry-out (beyond 128 bits) in CF
;
; Interface (custom/internal, but very common in bignum code):
;   add_u128_cf(a_lo, a_hi, b_lo, b_hi) -> RDX:RAX, CF
;   a_lo in RDI, a_hi in RSI, b_lo in RDX, b_hi in RCX
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson9_Ex8.asm -o ex8.o
;   ld -o ex8 ex8.o

global _start

section .text

add_u128_cf:
    mov     rax, rdi
    add     rax, rdx            ; low
    mov     rdx, rsi
    adc     rdx, rcx            ; high + carry
    ; CF is the carry-out beyond 128 bits
    ret

_start:
    ; case 1: (2^64-1,0) + (1,0) = (0,1), CF=0
    mov     rdi, 0xffffffffffffffff
    xor     rsi, rsi
    mov     rdx, 1
    xor     rcx, rcx
    call    add_u128_cf
    jc      .fail
    test    rax, rax
    jne     .fail
    cmp     rdx, 1
    jne     .fail

    ; case 2: (2^64-1,2^64-1) + (1,0) = (0,0), CF=1
    mov     rdi, 0xffffffffffffffff
    mov     rsi, 0xffffffffffffffff
    mov     rdx, 1
    xor     rcx, rcx
    call    add_u128_cf
    jnc     .fail
    test    rax, rax
    jne     .fail
    test    rdx, rdx
    jne     .fail

.ok:
    mov     eax, 60
    xor     edi, edi
    syscall

.fail:
    mov     eax, 60
    mov     edi, 1
    syscall

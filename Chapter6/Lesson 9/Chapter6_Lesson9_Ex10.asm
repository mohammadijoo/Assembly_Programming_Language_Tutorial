; Chapter6_Lesson9_Ex10.asm
; Programming Exercise (Solution):
; Multiply two 128-bit unsigned integers into a 256-bit product using sret.
;
; Representation:
;   u128 a = (a1:a0) where a0 is low64, a1 is high64
;   u128 b = (b1:b0)
;   u256 out = (p3:p2:p1:p0) as 4 qwords in little-endian limb order
;
; C model:
;   struct u256 { uint64_t p0,p1,p2,p3; };
;   struct u256 mul_u128_u128(uint64_t a0, uint64_t a1, uint64_t b0, uint64_t b1);
;
; Since the return object is 32 bytes, SysV ABI uses a hidden sret pointer:
;   out* in RDI, then a0 in RSI, a1 in RDX, b0 in RCX, b1 in R8
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson9_Ex10.asm -o ex10.o
;   ld -o ex10 ex10.o

global _start

section .text

mul_u128_u128_sret:
    ; preserve a1 because MUL uses RDX
    mov     r13, rdx            ; a1

    ; t0 = a0*b0
    mov     rax, rsi            ; a0
    mul     rcx                 ; b0 => RDX:RAX
    mov     [rdi + 0], rax      ; p0 = lo(t0)
    mov     r9, rdx             ; hi0 = hi(t0)

    ; t1 = a0*b1
    mov     rax, rsi            ; a0
    mul     r8                  ; b1
    mov     r11, rax            ; lo1
    mov     r12, rdx            ; hi1

    ; t2 = a1*b0
    mov     rax, r13            ; a1
    mul     rcx                 ; b0
    mov     r14, rax            ; lo2
    mov     r15, rdx            ; hi2

    ; t3 = a1*b1
    mov     rax, r13            ; a1
    mul     r8                  ; b1
    mov     r10, rax            ; lo3
    mov     rbx, rdx            ; hi3

    ; p1 = hi0 + lo1 + lo2, carry1 in r8 (0..2)
    mov     rax, r9
    add     rax, r11
    xor     r8, r8
    adc     r8, 0               ; carry from (hi0+lo1)
    add     rax, r14
    adc     r8, 0               ; carry_total in r8 (0..2)
    mov     [rdi + 8], rax      ; p1

    ; p2 = lo3 + hi1 + hi2 + carry1, carry2 in rcx
    mov     rax, r10
    add     rax, r12
    xor     rcx, rcx
    adc     rcx, 0
    add     rax, r15
    adc     rcx, 0
    add     rax, r8
    adc     rcx, 0
    mov     [rdi + 16], rax     ; p2

    ; p3 = hi3 + carry2
    mov     rax, rbx
    add     rax, rcx
    mov     [rdi + 24], rax     ; p3

    mov     rax, rdi            ; return sret pointer (common)
    ret

_start:
    ; Test with:
    ;   a = (a1:a0) = (1, 0xffffffffffffffff) = 2^65 - 1
    ;   b = (b1:b0) = (0, 2)
    ;   a*b = 2*(2^65 - 1) = 4*2^64 - 2
    ;   => p0 = 2^64 - 2, p1 = 3, p2 = 0, p3 = 0
    sub     rsp, 40
    lea     rdi, [rsp]                  ; out
    mov     rsi, 0xffffffffffffffff     ; a0
    mov     rdx, 1                      ; a1
    mov     rcx, 2                      ; b0
    xor     r8, r8                      ; b1
    call    mul_u128_u128_sret

    cmp     qword [rsp + 0], 0xfffffffffffffffe
    jne     .fail
    cmp     qword [rsp + 8], 3
    jne     .fail
    cmp     qword [rsp + 16], 0
    jne     .fail
    cmp     qword [rsp + 24], 0
    jne     .fail

.ok:
    add     rsp, 40
    mov     eax, 60
    xor     edi, edi
    syscall

.fail:
    add     rsp, 40
    mov     eax, 60
    mov     edi, 1
    syscall

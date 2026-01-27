; Chapter6_Lesson3_Ex11.asm
; Programming Exercise 2 (Hard): polynomial evaluation via Horner's method.
;
; Signature:
;   int64 poly_eval(const int64 *coeff, uint64 n, int64 x)
; where coeff[0..n-1] are coefficients for:
;   P(x) = coeff[0] + coeff[1]*x + ... + coeff[n-1]*x^(n-1)
; SysV: coeff=RDI, n=RSI, x=RDX
;
; Build:
;   nasm -f elf64 Chapter6_Lesson3_Ex11.asm -o ex11.o
;   ld -o ex11 ex11.o
; Run:
;   ./ex11 ; exit code = 86 for P(x)=1+2x+3x^2 at x=5

global _start

section .data
coeff dq 1, 2, 3      ; P(x)=1 + 2x + 3x^2
n     dq 3
xval  dq 5

section .text

poly_eval:
    xor     eax, eax          ; result = 0
    test    rsi, rsi
    jz      .done

    ; i = n-1
    lea     rcx, [rsi - 1]

.loop:
    imul    rax, rdx          ; result *= x
    add     rax, [rdi + rcx*8]; result += coeff[i]
    dec     rcx
    jns     .loop

.done:
    ret

_start:
    lea     rdi, [rel coeff]
    mov     rsi, [rel n]
    mov     rdx, [rel xval]
    call    poly_eval

    mov     edi, eax
    mov     eax, 60
    syscall

; Chapter6_Lesson9_Ex5.asm
; Returning a 16-byte "two-double" struct in XMM0/XMM1 (SysV ABI SSE-class).
;
; C model:
;   struct cplx { double re; double im; };
;   struct cplx cadd(struct cplx a, struct cplx b);
;
; SysV ABI typically passes the first 4 FP args in XMM0..XMM3.
; Returning two doubles is commonly done via XMM0 (re), XMM1 (im).
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson9_Ex5.asm -o ex5.o
;   ld -o ex5 ex5.o

global _start

section .data
a_re:    dq 0x3ff0000000000000    ; 1.0
a_im:    dq 0x4000000000000000    ; 2.0
b_re:    dq 0x4008000000000000    ; 3.0
b_im:    dq 0x4010000000000000    ; 4.0

exp_re:  dq 0x4010000000000000    ; 4.0
exp_im:  dq 0x4018000000000000    ; 6.0

tmp_re:  dq 0
tmp_im:  dq 0

section .text

cadd:
    ; a.re in XMM0, a.im in XMM1, b.re in XMM2, b.im in XMM3
    addsd   xmm0, xmm2
    addsd   xmm1, xmm3
    ret

_start:
    movsd   xmm0, [rel a_re]
    movsd   xmm1, [rel a_im]
    movsd   xmm2, [rel b_re]
    movsd   xmm3, [rel b_im]
    call    cadd

    movsd   [rel tmp_re], xmm0
    movsd   [rel tmp_im], xmm1

    mov     rax, [rel tmp_re]
    cmp     rax, [rel exp_re]
    jne     .fail
    mov     rax, [rel tmp_im]
    cmp     rax, [rel exp_im]
    jne     .fail

.ok:
    mov     eax, 60
    xor     edi, edi
    syscall

.fail:
    mov     eax, 60
    mov     edi, 1
    syscall

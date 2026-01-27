; Chapter5_Lesson9_Ex4.asm
; Readable switch-case via jump table with explicit bounds check and labeled cases.
; Operation selected by 'op' (0..3) on inputs a,b:
;   0: a+b
;   1: a-b
;   2: a*b  (low 32 bits)
;   3: max(a,b)
; default: returns -1
;
; Build:
;   nasm -felf64 Chapter5_Lesson9_Ex4.asm -o ex4.o
;   ld ex4.o -o ex4

BITS 64
DEFAULT REL

SECTION .rodata
jt:
    dq .L_case_add
    dq .L_case_sub
    dq .L_case_mul
    dq .L_case_max

SECTION .text
global _start

; do_op(op=edi, a=esi, b=edx) -> eax
do_op:
    cmp     edi, 3
    ja      .L_default
    mov     rax, [jt + rdi*8]
    jmp     rax

.L_case_add:
    lea     eax, [esi+edx]
    ret
.L_case_sub:
    mov     eax, esi
    sub     eax, edx
    ret
.L_case_mul:
    mov     eax, esi
    imul    eax, edx
    ret
.L_case_max:
    mov     eax, esi
    cmp     esi, edx
    jge     .L_max_done
    mov     eax, edx
.L_max_done:
    ret

.L_default:
    mov     eax, -1
    ret

_start:
    mov     edi, 3      ; op = max
    mov     esi, 25     ; a
    mov     edx, 40     ; b
    call    do_op

    ; Expect 40; exit 0 if ok else 1
    cmp     eax, 40
    jne     .L_fail
    xor     edi, edi
    mov     eax, 60
    syscall
.L_fail:
    mov     edi, 1
    mov     eax, 60
    syscall

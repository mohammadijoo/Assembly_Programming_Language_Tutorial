; Chapter6_Lesson9_Ex4.asm
; Returning multiple values via:
;   - quotient in RAX
;   - remainder in RDX
;   - error in CF (carry flag)
;
; This is NOT a language-level ABI guarantee, but is a common low-level pattern
; for assembly-only "internal ABI" routines.
;
; Signature (custom/internal):
;   udivmod_cf(uint64 a, uint64 b) -> RAX=q, RDX=r, CF=1 on error (b==0)
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson9_Ex4.asm -o ex4.o
;   ld -o ex4 ex4.o

global _start

section .text

udivmod_cf:
    ; a in RDI, b in RSI
    test    rsi, rsi
    jz      .err
    mov     rax, rdi
    xor     edx, edx
    div     rsi                 ; unsigned: quotient=RAX remainder=RDX
    clc                         ; CF=0 => ok
    ret
.err:
    xor     eax, eax
    xor     edx, edx
    stc                         ; CF=1 => error
    ret

_start:
    ; ok path: 100 / 9 = 11 rem 1
    mov     rdi, 100
    mov     rsi, 9
    call    udivmod_cf
    jc      .fail
    cmp     rax, 11
    jne     .fail
    cmp     rdx, 1
    jne     .fail

    ; error path: division by zero
    mov     rdi, 100
    xor     rsi, rsi
    call    udivmod_cf
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

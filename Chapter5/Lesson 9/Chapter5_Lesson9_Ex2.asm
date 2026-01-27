; Chapter5_Lesson9_Ex2.asm
; Structured loop template with explicit INIT/TEST/BODY/STEP blocks.
; Computes sum(bytes) over an array and verifies two loop styles match.
; Build:
;   nasm -felf64 Chapter5_Lesson9_Ex2.asm -o ex2.o
;   ld ex2.o -o ex2

BITS 64
DEFAULT REL

SECTION .rodata
arr: db  1,2,3,4,5,6,7,8
arr_len: equ $-arr

SECTION .text
global _start

; sum_for(arr, n) -> rax
sum_for:
    ; rdi=ptr, esi=n
    xor     eax, eax            ; sum = 0
    xor     ecx, ecx            ; i = 0
.L_for_test:
    cmp     ecx, esi
    jae     .L_for_done
.L_for_body:
    movzx   edx, byte [rdi+rcx]
    add     eax, edx
.L_for_step:
    inc     ecx
    jmp     .L_for_test
.L_for_done:
    ret

; sum_while(arr, n) -> rax
sum_while:
    xor     eax, eax            ; sum = 0
    mov     ecx, esi            ; remaining = n
    test    ecx, ecx
    jz      .L_while_done
.L_while_body:
    movzx   edx, byte [rdi]
    add     eax, edx
    inc     rdi
    dec     ecx
    jnz     .L_while_body
.L_while_done:
    ret

_start:
    lea     rdi, [arr]
    mov     esi, arr_len
    call    sum_for
    mov     ebx, eax            ; save sum1

    lea     rdi, [arr]
    mov     esi, arr_len
    call    sum_while
    cmp     eax, ebx
    jne     .L_fail

    ; success: exit 0
    xor     edi, edi
    mov     eax, 60
    syscall

.L_fail:
    mov     edi, 1
    mov     eax, 60
    syscall

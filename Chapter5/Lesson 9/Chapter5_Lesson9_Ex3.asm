; Chapter5_Lesson9_Ex3.asm
; Unified cleanup block pattern (single-exit discipline for non-trivial routines).
; Demonstrates "early error checks" + "one cleanup epilogue".
;
; The function validate_and_copy(dst, dst_cap, src, src_len) returns:
;   eax = 0 on success, non-zero error code otherwise.
;
; Build:
;   nasm -felf64 Chapter5_Lesson9_Ex3.asm -o ex3.o
;   ld ex3.o -o ex3

BITS 64
DEFAULT REL

SECTION .bss
dst_buf: resb 32

SECTION .rodata
src_buf: db "Structured assembly", 0
src_len: equ 17

SECTION .text
global _start

; validate_and_copy(dst=rdi, dst_cap=esi, src=rdx, src_len=ecx) -> eax
validate_and_copy:
    ; Prologue (simple frame; save only if needed)
    push    rbp
    mov     rbp, rsp
    push    rbx                ; example callee-saved use

    xor     eax, eax           ; assume success
    ; Guard checks (structured as early returns via jump to cleanup)
    test    rdi, rdi
    jz      .L_err_null
    test    rdx, rdx
    jz      .L_err_null
    cmp     ecx, 0
    jl      .L_err_len
    cmp     ecx, esi
    ja      .L_err_capacity

    ; Copy loop: for (i=0; i<src_len; i++) dst[i]=src[i]
    xor     ebx, ebx           ; i = 0
.L_copy_test:
    cmp     ebx, ecx
    jae     .L_copy_done
    mov     dl, [rdx+rbx]
    mov     [rdi+rbx], dl
    inc     ebx
    jmp     .L_copy_test
.L_copy_done:
    ; Null-terminate if there is room (dst_cap > src_len)
    cmp     ecx, esi
    jae     .L_cleanup
    mov     byte [rdi+rcx], 0
    jmp     .L_cleanup

.L_err_null:
    mov     eax, 10
    jmp     .L_cleanup
.L_err_len:
    mov     eax, 11
    jmp     .L_cleanup
.L_err_capacity:
    mov     eax, 12
    jmp     .L_cleanup

.L_cleanup:
    pop     rbx
    pop     rbp
    ret

_start:
    lea     rdi, [dst_buf]
    mov     esi, 32
    lea     rdx, [src_buf]
    mov     ecx, src_len
    call    validate_and_copy

    ; Exit with status = eax (0 success, non-zero error)
    mov     edi, eax
    mov     eax, 60
    syscall

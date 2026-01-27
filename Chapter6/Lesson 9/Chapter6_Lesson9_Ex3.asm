; Chapter6_Lesson9_Ex3.asm
; Returning a "large" struct via a hidden sret pointer (SysV AMD64 ABI).
;
; C model:
;   struct triple { int64_t a, b, c; };  // 24 bytes
;   struct triple triple_affine(int64_t x, int64_t y);
;
; SysV ABI (typical outcome for 24-byte integer struct):
;   caller allocates the return object and passes a hidden pointer as arg0 (RDI)
;   then real args shift right: x in RSI, y in RDX
;   callee writes into [RDI] and usually returns the same pointer in RAX
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson9_Ex3.asm -o ex3.o
;   ld -o ex3 ex3.o

global _start

section .text

triple_affine:
    ; void triple_affine(struct triple* out, int64 x, int64 y)
    ; out=RDI, x=RSI, y=RDX
    mov     [rdi + 0], rsi                  ; a = x
    mov     [rdi + 8], rdx                  ; b = y
    lea     rax, [rdx + rdx]                ; 2y
    add     rax, rsi                        ; x + 2y
    mov     [rdi + 16], rax                 ; c = x + 2y
    mov     rax, rdi                        ; return out pointer (common convention)
    ret

_start:
    ; allocate 32 bytes (keeps 16B alignment before call)
    sub     rsp, 32
    lea     rdi, [rsp]                      ; out
    mov     rsi, 7                          ; x
    mov     rdx, 5                          ; y
    call    triple_affine

    ; verify a=7, b=5, c=17
    cmp     qword [rsp + 0], 7
    jne     .fail
    cmp     qword [rsp + 8], 5
    jne     .fail
    cmp     qword [rsp + 16], 17
    jne     .fail

.ok:
    add     rsp, 32
    mov     eax, 60
    xor     edi, edi
    syscall

.fail:
    add     rsp, 32
    mov     eax, 60
    mov     edi, 1
    syscall

; Chapter6_Lesson9_Ex2.asm
; Returning a small struct (16 bytes) via RAX/RDX (SysV ABI integer-class).
;
; C model:
;   struct pair { int64_t sum; int64_t diff; };
;   struct pair sum_diff(int64_t x, int64_t y);
;
; SysV ABI typically returns a 16-byte integer-class struct in:
;   sum  -> RAX
;   diff -> RDX
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson9_Ex2.asm -o ex2.o
;   ld -o ex2 ex2.o

global _start

section .text

sum_diff:
    ; x in RDI, y in RSI
    mov     rax, rdi
    add     rax, rsi            ; sum
    mov     rdx, rdi
    sub     rdx, rsi            ; diff
    ret

_start:
    mov     rdi, 9
    mov     rsi, 4
    call    sum_diff            ; expect sum=13, diff=5

    cmp     rax, 13
    jne     .fail
    cmp     rdx, 5
    jne     .fail

.ok:
    mov     eax, 60
    xor     edi, edi
    syscall

.fail:
    mov     eax, 60
    mov     edi, 1
    syscall

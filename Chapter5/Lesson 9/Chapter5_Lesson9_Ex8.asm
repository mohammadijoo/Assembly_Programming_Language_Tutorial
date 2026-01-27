; Chapter5_Lesson9_Ex8.asm
; VERY HARD EXERCISE SOLUTION: Binary search on sorted int32 array with clean invariants.
;
; bsearch_i32(arr=rdi, n=esi, key=edx) -> eax
;   returns index (0..n-1) or -1 if not found.
;
; Invariant:
;   - search interval is [lo, hi) with 0 <= lo <= hi <= n
;   - key may only be in arr[lo..hi-1]
;
; Build:
;   nasm -felf64 Chapter5_Lesson9_Ex8.asm -o ex8.o
;   ld ex8.o -o ex8

BITS 64
DEFAULT REL

SECTION .rodata
arr: dd -10, -3, 0, 4, 9, 15, 22, 100
n:   equ 8

SECTION .text
global _start

bsearch_i32:
    push    rbp
    mov     rbp, rsp

    xor     ecx, ecx            ; lo = 0
    mov     r8d, esi            ; hi = n

.L_test:
    cmp     ecx, r8d            ; lo == hi?
    je      .L_not_found

    ; mid = lo + (hi-lo)/2
    mov     eax, r8d
    sub     eax, ecx
    shr     eax, 1
    add     eax, ecx            ; mid in eax

    ; v = arr[mid]
    movsxd  r9, eax
    mov     r10d, [rdi + r9*4]

    cmp     r10d, edx
    je      .L_found
    jl      .L_go_right

    ; v > key => hi = mid
    mov     r8d, eax
    jmp     .L_test

.L_go_right:
    ; v < key => lo = mid+1
    lea     ecx, [eax+1]
    jmp     .L_test

.L_found:
    ; return mid
    pop     rbp
    ret

.L_not_found:
    mov     eax, -1
    pop     rbp
    ret

_start:
    lea     rdi, [arr]
    mov     esi, n
    mov     edx, 15
    call    bsearch_i32
    cmp     eax, 5
    jne     .L_fail

    lea     rdi, [arr]
    mov     esi, n
    mov     edx, 7
    call    bsearch_i32
    cmp     eax, -1
    jne     .L_fail

    xor     edi, edi
    mov     eax, 60
    syscall

.L_fail:
    mov     edi, 1
    mov     eax, 60
    syscall

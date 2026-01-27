; Chapter 5 - Lesson 7 (Exercise 4 - Solution)
; Very hard: "Sparse switch" with sorted case keys and branch-minimized binary search.
;
; Cases: keys = { 3, 17, 19, 42, 100, 255 } return matching value else -1.
; Approach:
;   - store keys and results in arrays
;   - perform binary search (log2 N comparisons)
;   - avoid conditional branches on the compare direction by using CMOV.
;
; This is an alternative to jump tables when density is low.
;
; Build:
;   nasm -f elf64 Chapter5_Lesson7_Ex12.asm -o ex12.o

default rel
bits 64

section .text
global switch_sparse_bsearch

; int switch_sparse_bsearch(int x)
switch_sparse_bsearch:
    mov eax, edi

    xor ecx, ecx                   ; lo = 0
    mov edx, 5                     ; hi = 5 (N-1)

.loop:
    cmp ecx, edx
    ja  .not_found

    ; mid = (lo+hi)/2
    mov r8d, ecx
    add r8d, edx
    shr r8d, 1

    mov r9d, dword [keys + r8*4]
    cmp eax, r9d
    je  .found

    ; If x < key: hi = mid-1 else lo = mid+1
    mov r10d, r8d
    lea r11d, [r8d + 1]
    lea r10d, [r10d - 1]

    ; Use flags from cmp:
    cmovb edx, r10d                ; if below (unsigned), hi = mid-1
    cmova ecx, r11d                ; if above (unsigned), lo = mid+1
    jmp .loop

.found:
    mov eax, dword [vals + r8*4]
    ret

.not_found:
    mov eax, -1
    ret

section .rodata
keys: dd 3, 17, 19, 42, 100, 255
vals: dd 300, 1700, 1900, 4200, 10000, 25500

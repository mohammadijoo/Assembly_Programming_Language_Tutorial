bits 64
default rel

; Exercise 2 (solution):
; bounds_checked_load(base, n, idx):
;   if idx < n return base[idx] else return 0
; Use LEA to compute end pointer and avoid IMUL.

global _start

section .data
arr dd 11,22,33,44,55,66,77,88
n   equ 8

section .text
bounds_checked_load:
    ; rdi = base pointer (int32*)
    ; rsi = n (count)
    ; rdx = idx
    ; returns eax = value or 0
    ; end = base + n*4
    lea rcx, [rdi + rsi*4]     ; end pointer (one past last element)
    ; p = base + idx*4
    lea r8,  [rdi + rdx*4]
    cmp r8, rcx
    jae .oob                   ; p >= end  => out of bounds
    mov eax, [r8]
    ret
.oob:
    xor eax, eax
    ret

_start:
    lea rdi, [rel arr]
    mov esi, n
    mov edx, 6                 ; idx = 6, arr[6] = 77
    call bounds_checked_load

    ; exit status = 77
    mov eax, 60
    mov edi, 77
    syscall

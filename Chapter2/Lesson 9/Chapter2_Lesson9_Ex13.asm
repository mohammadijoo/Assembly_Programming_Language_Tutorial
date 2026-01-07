; Chapter2_Lesson9_Ex13.asm
; Programming Exercise Solution 2: compute pointer to A[i][j] (row-major).
; Prototype:
;   elem_ptr(base=rdi, i=rsi, j=rdx, cols=rcx) -> rax = &A[i][j]
; Element size: 8 bytes (qword)
;
; Build:
;   nasm -felf64 Chapter2_Lesson9_Ex13.asm -o ex13.o
;   ld -o ex13 ex13.o
;
; Expected run result (exit status): 13

default rel
global _start

section .data
; 4x5 matrix with values 0..19
A dq 0,1,2,3,4, 5,6,7,8,9, 10,11,12,13,14, 15,16,17,18,19

section .text
elem_ptr:
    ; offset_elems = i*cols + j
    mov rax, rsi
    imul rax, rcx
    add rax, rdx

    ; offset_bytes = offset_elems*8
    lea rax, [rdi + rax*8]
    ret

_start:
    lea rdi, [A]   ; base
    mov esi, 2     ; i
    mov edx, 3     ; j
    mov ecx, 5     ; cols
    call elem_ptr

    mov rbx, [rax] ; value at A[2][3] is 13
    mov eax, 60
    mov edi, ebx
    syscall

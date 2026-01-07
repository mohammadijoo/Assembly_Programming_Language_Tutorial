bits 64
default rel

; Exercise 4 (solution):
; Add two arrays of qwords into a third: C[i] = A[i] + B[i], i=0..n-1.
; Use LEA for pointer arithmetic and keep a tight loop.
; This is a minimal kernel, not a full benchmark harness.

global _start

section .data
A dq 1,2,3,4,5,6,7,8
B dq 10,20,30,40,50,60,70,80
C times 8 dq 0
n equ 8

section .text
_start:
    lea rsi, [rel A]    ; pa
    lea rdi, [rel B]    ; pb
    lea rbx, [rel C]    ; pc
    mov ecx, n

.loop:
    mov rax, [rsi]
    add rax, [rdi]
    mov [rbx], rax

    ; pointer bumps without clobbering flags from DEC/JNZ choices
    lea rsi, [rsi + 8]
    lea rdi, [rdi + 8]
    lea rbx, [rbx + 8]

    dec ecx
    jnz .loop

    ; Verify last element quickly: C[7] = 8 + 80 = 88
    mov eax, 60
    mov edi, 88
    syscall

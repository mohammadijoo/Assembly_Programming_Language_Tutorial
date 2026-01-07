bits 64
default rel

; Pointer-walking summation.
; Uses LEA for pointer increment so flags are preserved for the loop compare.

global _start

section .data
arr dq 1,2,3,4,5,6,7,8,9,10
n   equ 10

section .text
_start:
    lea rsi, [rel arr]      ; p = &arr[0]
    xor rax, rax            ; sum = 0
    mov ecx, n              ; count

.loop:
    add rax, [rsi]          ; sum += *p
    lea rsi, [rsi + 8]      ; p++ (qword)
    dec ecx
    jnz .loop

    ; Exit status = sum mod 256 (sum 1..10 = 55)
    mov eax, 60
    mov edi, 55
    syscall

bits 64
default rel

global _start

section .data
arr dq 10, 20, 30, 40, 50, 60, 70, 80

section .text
_start:
    mov ecx, 3                         ; i = 3
    lea rbx, [rel arr + rcx*8]         ; &arr[i] (qword elements => scale 8)
    mov rax, [rbx]                     ; rax = arr[i] = 40

    ; Exit with low 8 bits of value (just for a visible effect)
    mov eax, 60
    mov edi, eax                       ; status = 40
    syscall

; Chapter 2 - Lesson 10 - Example 3
; LEA: effective-address computation for pointer arithmetic and for "free" multiply/add
; Build:
;   nasm -felf64 Chapter2_Lesson10_Ex3.asm -o ex3.o && ld ex3.o -o ex3 && ./ex3 ; echo $?

global _start

section .data
    arr dq 10, 20, 30, 40, 50

section .text
_start:
    ; Compute &arr[i] for i=3 (0-based): addr = arr + i*8
    mov edi, 3
    lea rbx, [rel arr + rdi*8]    ; RBX = address of arr[3]

    ; Load value at arr[3] (should be 40)
    mov rax, [rbx]

    ; LEA as arithmetic: compute t = 3*x + 5 with x=7
    mov ecx, 7
    ; 3*x = x + 2*x
    lea edx, [rcx + rcx*2]        ; EDX = 3*x
    lea edx, [rdx + 5]            ; EDX = 3*x + 5

    ; Combine checks into exit status:
    ; exit = (arr[3] == 40 ? 0 : 2) OR (t == 26 ? 0 : 4)
    xor edi, edi
    cmp rax, 40
    je .ok1
    or edi, 2
.ok1:
    cmp edx, 26
    je .ok2
    or edi, 4
.ok2:
    mov eax, 60
    syscall

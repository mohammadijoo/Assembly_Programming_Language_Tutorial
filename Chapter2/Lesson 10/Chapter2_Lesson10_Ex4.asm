; Chapter 2 - Lesson 10 - Example 4
; LEA vs MOV: address-of vs load-from (a classic pointer bug)
; Build:
;   nasm -felf64 Chapter2_Lesson10_Ex4.asm -o ex4.o && ld ex4.o -o ex4 && ./ex4 ; echo $?

global _start

section .data
    value dq 0x1122334455667788
    p     dq value             ; p holds the address of value (a pointer)

section .text
_start:
    ; MOV reads memory: rax = *p  (loads the pointer value, i.e., address of 'value')
    mov rax, [rel p]

    ; LEA computes address: rbx = &p (address of the variable p itself)
    lea rbx, [rel p]

    ; If you intended to load *value*, you need two steps:
    ;   mov rax, [p]   ; rax = value's address
    ;   mov rax, [rax] ; rax = *value

    mov rcx, rax       ; rcx = p (address of 'value')
    mov rdx, [rcx]     ; rdx = *p == value content

    ; Sanity checks:
    ; 1) rax != rbx (p is stored somewhere; its contents differ from its own address)
    ; 2) rdx equals value
    xor edi, edi
    cmp rax, rbx
    jne .ok1
    or edi, 1
.ok1:
    cmp rdx, [rel value]
    je .ok2
    or edi, 2
.ok2:
    mov eax, 60
    syscall

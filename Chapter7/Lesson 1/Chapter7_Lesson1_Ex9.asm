; Chapter 7 - Lesson 1
; Exercise Solution 3 (Hard):
;   Evaluate an RPN (Reverse Polish Notation) expression using the CPU stack.
;
; Input expression (ASCII, bytes):
;   - digits '0'..'9' push their integer value
;   - '+' and '*' pop two values and push the result
; Example: "23+5*"  => (2+3)*5 = 25
;
; We return the final result as the process exit code (mod 256).
;
; Build:
;   nasm -felf64 Chapter7_Lesson1_Ex9.asm -o ex9.o
;   ld -o ex9 ex9.o
;   ./ex9 ; echo $?

global _start

section .data
expr: db "23+5*",0

section .text

_start:
    lea rsi, [rel expr]

.next:
    mov al, [rsi]
    test al, al
    jz .done
    inc rsi

    cmp al, '0'
    jb .op
    cmp al, '9'
    ja .op

    ; digit: push value
    sub al, '0'
    movzx rax, al
    push rax
    jmp .next

.op:
    cmp al, '+'
    je .add
    cmp al, '*'
    je .mul
    ; ignore unknown chars (spaces, etc.)
    jmp .next

.add:
    pop rbx
    pop rax
    add rax, rbx
    push rax
    jmp .next

.mul:
    pop rbx
    pop rax
    imul rax, rbx
    push rax
    jmp .next

.done:
    pop rax                  ; final value
    mov edi, eax             ; exit code (low 32 bits, kernel uses low 8 for shell)
    mov eax, 60
    syscall

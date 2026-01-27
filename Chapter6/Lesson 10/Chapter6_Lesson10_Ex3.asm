; Chapter 6 - Lesson 10 (Ex3): SysV AMD64 - Implementing an integer-only variadic function
; Signature (C view): long sum_ints(long count, ...);
; Varargs are assumed to be 64-bit integers (e.g., long on LP64).
;
; Build (Linux x86-64):
;   nasm -f elf64 Chapter6_Lesson10_Ex3.asm -o ex3.o
;   gcc -no-pie ex3.o -o ex3
; Run:
;   ./ex3

default rel
bits 64

extern printf
global main
global sum_ints

section .rodata
fmt: db "sum_ints(%ld, ...) = %ld", 10, 0

section .text
; long sum_ints(long count, ...);
sum_ints:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 40                 ; locals (5 qwords), keep alignment friendly

    ; Save the 5 GP vararg registers (RSI, RDX, RCX, R8, R9) as a contiguous array
    mov [rbp-48], rsi           ; vararg[0]
    mov [rbp-40], rdx           ; vararg[1]
    mov [rbp-32], rcx           ; vararg[2]
    mov [rbp-24], r8            ; vararg[3]
    mov [rbp-16], r9            ; vararg[4]

    mov rbx, rdi                ; count
    xor rax, rax                ; accumulator
    xor r10d, r10d              ; i = 0

.loop:
    cmp r10, rbx
    jae .done

    cmp r10, 5
    jb .from_regs

    ; vararg[i] is on stack when i >= 5
    mov r11, r10
    sub r11, 5
    mov rdx, [rbp + 16 + r11*8] ; first stack vararg is at [rbp+16]
    jmp .add

.from_regs:
    mov rdx, [rbp - 48 + r10*8]

.add:
    add rax, rdx
    inc r10
    jmp .loop

.done:
    add rsp, 40
    pop rbx
    leave
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 64                 ; room for stack args + alignment

    ; Call sum_ints(8, 1,2,3,4,5,6,7,8)
    ; count in RDI; first 5 varargs in RSI,RDX,RCX,R8,R9; remaining on stack.
    mov qword [rsp + 0], 6
    mov qword [rsp + 8], 7
    mov qword [rsp +16], 8
    ; [rsp+24..] unused padding, but keeps stack aligned

    mov rdi, 8
    mov rsi, 1
    mov rdx, 2
    mov rcx, 3
    mov r8,  4
    mov r9,  5

    xor eax, eax                ; AL=0 vector regs used
    call sum_ints
    ; RAX = result

    ; Print result: printf(fmt, count, result)
    mov rdi, fmt
    mov rsi, 8
    mov rdx, rax
    xor eax, eax
    call printf

    xor eax, eax
    leave
    ret

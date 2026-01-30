; Chapter7_Lesson2_Ex11.asm
; Chapter 7, Lesson 2 — Programming Exercise 3 (Solution)
; Very hard: Fibonacci with memoization stored on the stack (bounded).
; Prototype: unsigned long fib_memo(unsigned int n, unsigned long* cache)
; cache[i] holds fib(i) or -1 (all bits 1) if unknown.
;
; Build (Linux x86-64):
;   nasm -f elf64 Chapter7_Lesson2_Ex11.asm -o ex11.o
;   gcc -no-pie ex11.o -o ex11
; Run:
;   ./ex11

default rel
extern printf
global main

%define MAX_N  50              ; bounded cache and recursion depth for demo

section .rodata
fmt: db "fib(%u) = %lu", 10, 0

section .text
fib_memo:
    ; rdi = n (use edi), rsi = cache pointer
    push rbp
    mov rbp, rsp
    sub rsp, 48                ; locals, keeps alignment for recursive calls

    mov [rbp-8], rsi            ; save cache pointer

    mov eax, edi
    cmp eax, MAX_N
    jb .n_ok
    mov eax, MAX_N-1
    mov edi, eax
.n_ok:
    mov [rbp-16], edi           ; save n (32-bit)

    ; if cache[n] != -1, return it
    mov eax, [rbp-16]
    mov rsi, [rbp-8]
    lea rdx, [rsi + rax*8]
    mov rax, [rdx]
    cmp rax, -1
    jne .ret

    ; base cases n=0,1
    cmp dword [rbp-16], 1
    ja .recur
    mov eax, [rbp-16]           ; 0 or 1
    mov rsi, [rbp-8]
    mov ecx, [rbp-16]
    lea rdx, [rsi + rcx*8]
    mov [rdx], rax
    jmp .ret

.recur:
    ; fib(n-1)
    mov eax, [rbp-16]
    dec eax
    mov edi, eax
    mov rsi, [rbp-8]
    call fib_memo
    mov [rbp-24], rax           ; save fib(n-1)

    ; fib(n-2)
    mov eax, [rbp-16]
    sub eax, 2
    mov edi, eax
    mov rsi, [rbp-8]
    call fib_memo

    add rax, [rbp-24]           ; fib(n) = fib(n-1) + fib(n-2)

    ; store cache[n] = rax
    mov rsi, [rbp-8]
    mov ecx, [rbp-16]
    lea rdx, [rsi + rcx*8]
    mov [rdx], rax

.ret:
    leave
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 512                ; reserve space (cache + locals), aligned

    ; cache starts at rsp (bottom of allocated area)
    mov [rbp-8], rsp            ; save cache pointer for convenience

    ; initialize cache[i] = -1 for i in [0, MAX_N)
    xor ecx, ecx
.init:
    cmp ecx, MAX_N
    jge .init_done
    mov rdx, [rbp-8]
    mov qword [rdx + rcx*8], -1
    inc ecx
    jmp .init

.init_done:
    ; set cache[0]=0, cache[1]=1
    mov rdx, [rbp-8]
    mov qword [rdx + 0*8], 0
    mov qword [rdx + 1*8], 1

    ; compute fib(n)
    mov edi, 40                 ; n (bounded by MAX_N)
    mov rsi, [rbp-8]            ; cache pointer
    call fib_memo               ; rax = fib(n)

    lea rdi, [fmt]
    mov esi, 40
    mov rdx, rax
    xor eax, eax
    call printf

    xor eax, eax
    leave
    ret

; Chapter 6 - Lesson 11, Exercise 3 (with solution)
; File: Chapter6_Lesson11_Ex10.asm
; Topic: Leaf sum array with overflow detection (sets RDX=1 on overflow)
; Build:
;   nasm -felf64 Chapter6_Lesson11_Ex10.asm -o ex10.o
;   ld -o ex10 ex10.o
; Run:
;   ./ex10 ; exit code 0 means no overflow and correct sum check

global _start

section .data
arr dq 0x7FFFFFFFFFFFFFF0, 0x30   ; will overflow signed 64-bit on addition

section .text

; int64_t sum_i64_checked(const int64_t* p, uint64_t n, uint64_t* overflow_flag)
; p in RDI, n in RSI, overflow_flag in RDX (pointer)
; returns sum in RAX, and writes 0/1 to *overflow_flag
sum_i64_checked:
    xor rax, rax
    xor r8d, r8d               ; r8 = overflow = 0
    test rsi, rsi
    jz .store

.loop:
    mov rcx, [rdi]
    add rax, rcx
    jo .overflow
    add rdi, 8
    dec rsi
    jnz .loop
    jmp .store

.overflow:
    mov r8d, 1
    ; still consume remaining elements (optional policy). We'll stop here for determinism.
.store:
    mov [rdx], r8              ; write overflow flag
    ret

_start:
    sub rsp, 8                 ; reserve space for overflow_flag (and keep alignment simple)
    lea rdi, [arr]
    mov rsi, 2
    mov rdx, rsp               ; overflow_flag pointer
    call sum_i64_checked

    ; Expect overflow_flag == 1
    mov rbx, [rsp]
    add rsp, 8

    cmp rbx, 1
    jne .fail

    xor edi, edi
    mov eax, 60
    syscall

.fail:
    mov edi, 2
    mov eax, 60
    syscall

; Chapter 7 - Lesson 1
; Exercise Solution 4 (Very Hard, conceptual safety pattern):
;   "Poor man's" stack canary: place a canary in a local slot and verify on return.
;
; This is NOT a replacement for real compiler/OS canaries, but it teaches the idea:
;   - store a value near the end of the frame
;   - before returning, check it is unchanged
; If a buffer overflow overwrote the canary, you detect corruption.
;
; Build:
;   nasm -felf64 Chapter7_Lesson1_Ex10.asm -o ex10.o
;   ld -o ex10 ex10.o
;   ./ex10

global _start

section .data
ok:  db "OK: canary intact",10
ok_l: equ $-ok
bad: db "FAIL: canary corrupted",10
bad_l: equ $-bad

section .text

_start:
    call protected_function
    xor edi, edi
    mov eax, 60
    syscall

; protected_function():
;   local layout (after prologue):
;     [rbp-8]  canary
;     [rbp-40] buffer[32]   (grows "down" in memory)
protected_function:
    push rbp
    mov rbp, rsp
    sub rsp, 64

    ; canary = (RBP xor RSP) ^ constant (cheap mixing; not cryptographic)
    mov rax, rbp
    xor rax, rsp
    xor rax, 0x9e3779b97f4a7c15
    mov [rbp-8], rax

    ; safe write within buffer bounds
    lea rdi, [rbp-40]     ; buffer
    mov ecx, 32
    mov al, 0x41          ; 'A'
.fill:
    mov [rdi], al
    inc rdi
    loop .fill

    ; Uncomment the next block to simulate an overflow that trashes the canary:
    ; lea rdi, [rbp-40]
    ; mov ecx, 64
    ; mov al, 0x42
    ; .overflow:
    ;   mov [rdi], al
    ;   inc rdi
    ;   loop .overflow

    ; verify canary
    mov rax, rbp
    xor rax, rsp
    xor rax, 0x9e3779b97f4a7c15
    cmp rax, [rbp-8]
    jne .corrupt

    mov rdi, ok
    mov rsi, ok_l
    call write_buf
    leave
    ret

.corrupt:
    mov rdi, bad
    mov rsi, bad_l
    call write_buf
    ; In real systems, you'd abort or trigger a fast-fail here.
    mov edi, 1
    mov eax, 60
    syscall

write_buf:
    mov eax, 1
    mov edi, 1
    mov rdx, rsi
    mov rsi, rdi
    syscall
    ret

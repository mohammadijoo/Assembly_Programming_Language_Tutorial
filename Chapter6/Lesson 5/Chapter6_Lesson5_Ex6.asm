bits 64
default rel
global _start

%define CACHE_SIZE 94         ; enough up to fib(93) in uint64

section .bss
fib_cache: resq CACHE_SIZE

section .text
_start:
    ; Initialize cache to -1, then seed fib(0)=0 and fib(1)=1.
    lea rdi, [rel fib_cache]
    mov ecx, CACHE_SIZE
    mov rax, -1
.init:
    mov [rdi], rax
    add rdi, 8
    dec ecx
    jnz .init

    mov qword [rel fib_cache + 0], 0
    mov qword [rel fib_cache + 8], 1

    ; Compute fib(40) = 102334155
    mov edi, 40
    call fib_memo

    mov rcx, 102334155
    cmp rax, rcx
    jne .bad

.good:
    xor edi, edi
    mov eax, 60
    syscall

.bad:
    mov edi, 1
    mov eax, 60
    syscall

; uint64_t fib_memo(uint64_t n)
; - Uses fib_cache[n] if available
; - Recurrence: fib(n)=fib(n-1)+fib(n-2)
fib_memo:
    cmp rdi, 1
    jbe .base

    push rbp
    mov rbp, rsp
    sub rsp, 32               ; locals + alignment

    mov [rbp-8], rdi          ; save n

    lea r8, [rel fib_cache]
    mov r9, [r8 + rdi*8]
    cmp r9, -1
    jne .cached

    mov rdi, [rbp-8]
    dec rdi
    call fib_memo
    mov [rbp-16], rax         ; save fib(n-1)

    mov rdi, [rbp-8]
    sub rdi, 2
    call fib_memo
    add rax, [rbp-16]         ; fib(n-2) + fib(n-1)

    mov rdi, [rbp-8]
    lea r8, [rel fib_cache]
    mov [r8 + rdi*8], rax     ; cache[n] = result

    leave
    ret

.cached:
    mov rax, r9
    leave
    ret

.base:
    mov rax, rdi              ; fib(0)=0, fib(1)=1
    ret

; Chapter 6 - Lesson 8 (Exercise 3 Solution)
; Very hard: map-reduce style loop that repeatedly calls a callback function pointer.
; Demonstrates: when you CALL an unknown callback, treat *all* caller-saved regs as clobbered each iteration.
; Build (Linux x86-64):
;   nasm -felf64 Chapter6_Lesson8_Ex12.asm -o ex12.o
;   ld -o ex12 ex12.o
;   ./ex12
;
; API:
;   uint64_t map_sum_u64(uint64_t* arr, uint64_t n, uint64_t (*fn)(uint64_t));
; SysV AMD64:
;   arr=rdi, n=rsi, fn=rdx; returns rax

BITS 64
default rel
global _start

section .rodata
msg_ok   db "OK: map_sum_u64 produced expected result", 10
len_ok   equ $-msg_ok
msg_fail db "FAIL", 10
len_fail equ $-msg_fail

section .data
arr dq 1,2,3,4,5

section .text
write_msg:
    mov eax, 1
    mov edi, 1
    syscall
    ret

square_u64:
    ; x in rdi, returns rax = x*x
    mov rax, rdi
    imul rax, rdi
    ret

map_sum_u64:
    ; rdi=arr, rsi=n, rdx=fn
    ; returns rax=sum(fn(arr[i]))
    ; Uses RBX (i), R12 (arr), R13 (n), R14 (fn), R15 (acc) => callee-saved
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8              ; 5 pushes (odd) -> align for CALL

    mov r12, rdi
    mov r13, rsi
    mov r14, rdx
    xor r15, r15
    xor ebx, ebx

.loop:
    cmp rbx, r13
    jae .done

    mov rdi, [r12 + rbx*8]  ; arg to callback
    call r14                ; unknown code: clobbers all caller-saved regs
    add r15, rax            ; accumulator in callee-saved reg

    inc rbx
    jmp .loop

.done:
    mov rax, r15
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

_start:
    lea rdi, [rel arr]
    mov rsi, 5
    lea rdx, [rel square_u64]
    call map_sum_u64

    ; expected: 1^2+2^2+3^2+4^2+5^2 = 55
    cmp rax, 55
    jne .fail

    lea rsi, [rel msg_ok]
    mov edx, len_ok
    call write_msg
    mov eax, 60
    xor edi, edi
    syscall

.fail:
    lea rsi, [rel msg_fail]
    mov edx, len_fail
    call write_msg
    mov eax, 60
    mov edi, 1
    syscall

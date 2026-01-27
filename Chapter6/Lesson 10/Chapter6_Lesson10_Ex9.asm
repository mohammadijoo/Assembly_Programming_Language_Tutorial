; Chapter 6 - Lesson 10 (Ex9): SysV AMD64 - VERY HARD: dynamically call a function with N integer args
; We implement:
;   long call_ints(long (*fn)(), long n, const long *args);
; which calls fn(args[0], args[1], ..., args[n-1]) for 0 <= n <= 10.
; Only GP integer/pointer args are supported (no FP/vector).
;
; This resembles what a JIT/FFI trampoline must do.
;
; Build (Linux x86-64):
;   nasm -f elf64 Chapter6_Lesson10_Ex9.asm -o ex9.o
;   gcc -no-pie ex9.o -o ex9
; Run:
;   ./ex9

default rel
bits 64

extern printf
global main
global call_ints
global add10

section .rodata
fmt: db "call_ints(add10, 10, args) = %ld", 10, 0

section .data
args: dq 1,2,3,4,5,6,7,8,9,10

section .text
; long add10(long a0,a1,a2,a3,a4,a5,a6,a7,a8,a9) = sum of 10 args
add10:
    mov rax, rdi
    add rax, rsi
    add rax, rdx
    add rax, rcx
    add rax, r8
    add rax, r9
    add rax, [rsp + 8]          ; a6 (1st stack arg)
    add rax, [rsp + 16]         ; a7
    add rax, [rsp + 24]         ; a8
    add rax, [rsp + 32]         ; a9
    ret

; long call_ints(long (*fn)(), long n, const long *args)
; RDI=fn, RSI=n, RDX=args
call_ints:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13

    mov r13, rdi                ; fn
    mov r12, rsi                ; n
    mov rbx, rdx                ; args

    ; compute stack_args = max(0, n-6)
    xor r8d, r8d
    cmp r12, 6
    jbe .have_stack_args
    mov r8, r12
    sub r8, 6                   ; r8 = stack_args
.have_stack_args:

    ; bytes = stack_args * 8
    mov r9, r8
    shl r9, 3                   ; r9 = bytes

    ; padding to keep RSP 16-aligned before CALL
    ; At this point, after pushes: entry rsp%16=8, push rbp =>0, push rbx =>8, push r12=>0, push r13=>8
    ; So current RSP%16=8. We need (RSP - alloc)%16 == 0 before CALL.
    ; If alloc%16 == 8 -> good; if alloc%16 == 0 -> need extra 8.
    mov r10, r9
    and r10, 15
    cmp r10, 8
    je .alloc_ok
    add r9, 8                   ; add padding
.alloc_ok:

    sub rsp, r9                 ; reserve stack space for extra args (+ padding)

    ; copy stack args (args[6]..args[n-1]) into the reserved area in increasing order
    ; such that, at CALL, the first stack arg is at [rsp] in caller (becomes [rsp+8] in callee).
    xor r11d, r11d              ; i = 6
    cmp r12, 6
    jbe .load_regs

.copy_loop:
    cmp r11, r12
    jae .load_regs
    ; dest offset = (i-6)*8
    mov rax, r11
    sub rax, 6
    mov rdx, [rbx + r11*8]
    mov [rsp + rax*8], rdx
    inc r11
    jmp .copy_loop

.load_regs:
    ; load up to first 6 args into registers, missing args treated as 0
    xor rdi, rdi
    xor rsi, rsi
    xor rdx, rdx
    xor rcx, rcx
    xor r8,  r8
    xor r9,  r9

    cmp r12, 0
    je .do_call
    mov rdi, [rbx + 0]

    cmp r12, 1
    je .do_call
    mov rsi, [rbx + 8]

    cmp r12, 2
    je .do_call
    mov rdx, [rbx + 16]

    cmp r12, 3
    je .do_call
    mov rcx, [rbx + 24]

    cmp r12, 4
    je .do_call
    mov r8,  [rbx + 32]

    cmp r12, 5
    je .do_call
    mov r9,  [rbx + 40]

.do_call:
    xor eax, eax                ; AL=0 vector regs
    call r13

    ; restore stack
    add rsp, r9

    pop r13
    pop r12
    pop rbx
    leave
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    lea rdi, [add10]            ; fn
    mov rsi, 10                 ; n
    lea rdx, [args]             ; args*
    call call_ints              ; RAX = result

    mov rdi, fmt
    mov rsi, rax
    xor eax, eax
    call printf

    xor eax, eax
    leave
    ret

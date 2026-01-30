; Chapter7_Lesson2_Ex12.asm
; Chapter 7, Lesson 2 — Programming Exercise 4 (Solution)
; Very hard (defensive): Copy a C-string into a fixed local buffer with a canary check.
; The function copies at most 31 bytes plus terminator into a local buffer[32].
; Return: length on success, -1 if the string does not fit, -2 if canary check fails.
;
; Build (Linux x86-64):
;   nasm -f elf64 Chapter7_Lesson2_Ex12.asm -o ex12.o
;   gcc -no-pie ex12.o -o ex12
; Run:
;   ./ex12

default rel
extern printf
global main

%define CANARY 0x1122334455667788

section .rodata
fmt_ok:  db "copied len=%ld  buf=%s", 10, 0
fmt_res: db "return value=%ld", 10, 0

section .data
s_ok:  db "stack frames are discipline", 0
s_bad: db "this string is intentionally longer than thirty one bytes", 0

section .text
copy_local_checked:
    ; rdi = src pointer
    push rbp
    mov rbp, rsp
    sub rsp, 96                 ; space for buf + locals, aligned

    ; layout:
    ; [rbp-8]   canary
    ; [rbp-16]  return value spill
    ; [rbp-64]..[rbp-33] buffer (32 bytes)
    mov qword [rbp-8], CANARY

    lea rdx, [rbp-64]           ; rdx = buf
    xor rcx, rcx                ; i = 0

.copy_loop:
    mov al, [rdi + rcx]
    mov [rdx + rcx], al
    test al, al
    jz .success

    inc rcx
    cmp rcx, 31
    jb .copy_loop

    ; i reached 31 and still not terminated: does not fit
    mov rax, -1
    jmp .check

.success:
    ; rcx is length (excluding terminator)
    mov rax, rcx
    mov [rbp-16], rax           ; preserve across printf

    lea rdi, [fmt_ok]
    mov rsi, [rbp-16]           ; len
    lea rdx, [rbp-64]           ; buf
    xor eax, eax
    call printf

    mov rax, [rbp-16]           ; restore return value

.check:
    cmp qword [rbp-8], CANARY
    jne .canary_fail
    leave
    ret

.canary_fail:
    mov rax, -2
    leave
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    ; Test with short string
    lea rdi, [s_ok]
    call copy_local_checked
    lea rdi, [fmt_res]
    mov rsi, rax
    xor eax, eax
    call printf

    ; Test with too-long string
    lea rdi, [s_bad]
    call copy_local_checked
    lea rdi, [fmt_res]
    mov rsi, rax
    xor eax, eax
    call printf

    xor eax, eax
    leave
    ret

; Chapter 7 - Lesson 4 - Example 3
; realloc-driven growth: build a string that appends '!' many times.
; Demonstrates capacity/length bookkeeping and realloc failure discipline.
; Build (Linux x86-64):
;   nasm -felf64 Chapter7_Lesson4_Ex3.asm -o ex3.o
;   gcc -no-pie ex3.o -o ex3

default rel

global main
extern malloc
extern realloc
extern free
extern printf
extern exit

section .data
fmt_s   db "%s", 10, 0
msg_oom db "allocation failed", 10, 0

section .text
main:
    push rbp
    mov  rbp, rsp
    sub  rsp, 96

    ; cap = 16
    mov  qword [rbp-16], 16
    ; len = 5  (for "Hello")
    mov  qword [rbp-24], 5

    mov  rdi, [rbp-16]
    call malloc
    test rax, rax
    jz   .oom

    mov  [rbp-8], rax       ; buf*

    ; buf = "Hello\0"
    mov  rdx, [rbp-8]
    mov  byte [rdx+0], 'H'
    mov  byte [rdx+1], 'e'
    mov  byte [rdx+2], 'l'
    mov  byte [rdx+3], 'l'
    mov  byte [rdx+4], 'o'
    mov  byte [rdx+5], 0

    xor  ecx, ecx           ; i = 0
.append_loop:
    cmp  ecx, 100
    jge  .print

    ; need len + 2 <= cap  (one char + null terminator)
    mov  rax, [rbp-24]       ; len
    add  rax, 2
    mov  rdx, [rbp-16]       ; cap
    cmp  rax, rdx
    jbe  .have_space

.grow:
    ; cap *= 2
    shl  qword [rbp-16], 1

    mov  rdi, [rbp-8]        ; old buf
    mov  rsi, [rbp-16]       ; new cap
    call realloc
    test rax, rax
    jz   .realloc_fail

    mov  [rbp-8], rax        ; buf = newbuf

.have_space:
    mov  rdx, [rbp-8]
    mov  rax, [rbp-24]       ; len
    mov  byte [rdx+rax], '!'
    inc  qword [rbp-24]
    mov  rax, [rbp-24]
    mov  byte [rdx+rax], 0

    inc  ecx
    jmp  .append_loop

.print:
    lea  rdi, [fmt_s]
    mov  rsi, [rbp-8]
    xor  eax, eax
    call printf

    mov  rdi, [rbp-8]
    call free

    xor  eax, eax
    leave
    ret

.realloc_fail:
    ; realloc failed: old pointer remains valid; free it.
    mov  rdi, [rbp-8]
    call free
    jmp  .oom

.oom:
    lea  rdi, [msg_oom]
    xor  eax, eax
    call printf
    mov  edi, 1
    call exit

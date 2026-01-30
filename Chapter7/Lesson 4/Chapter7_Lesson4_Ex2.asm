; Chapter 7 - Lesson 4 - Example 2
; calloc for a zeroed array of 16-byte records: {qword id, qword value}
; Initialize and print.
; Build (Linux x86-64):
;   nasm -felf64 Chapter7_Lesson4_Ex2.asm -o ex2.o
;   gcc -no-pie ex2.o -o ex2

default rel

global main
extern calloc
extern free
extern printf
extern exit

section .data
fmt_row db "node[%ld]: id=%ld value=%ld", 10, 0
msg_oom db "calloc failed", 10, 0

section .text
main:
    push rbp
    mov  rbp, rsp
    sub  rsp, 64

    ; calloc(5, 16)
    mov  edi, 5
    mov  esi, 16
    call calloc
    test rax, rax
    jz   .oom

    mov  [rbp-8], rax       ; base pointer

    ; init: node[i].id=i, node[i].value=i*i
    xor  ecx, ecx
.init_loop:
    cmp  ecx, 5
    jge  .print_prep

    mov  rdx, [rbp-8]
    lea  rdx, [rdx + rcx*16]

    mov  rax, rcx
    mov  [rdx+0], rax

    mov  rax, rcx
    imul rax, rcx
    mov  [rdx+8], rax

    inc  ecx
    jmp  .init_loop

.print_prep:
    xor  ecx, ecx

.print_loop:
    cmp  ecx, 5
    jge  .done

    mov  [rbp-16], rcx      ; save index across printf

    mov  r10, [rbp-8]
    lea  r10, [r10 + rcx*16]
    mov  r9,  [r10+0]       ; id
    mov  r8,  [r10+8]       ; value

    lea  rdi, [fmt_row]
    mov  rsi, [rbp-16]      ; index
    mov  rdx, r9            ; id
    mov  rcx, r8            ; value
    xor  eax, eax
    call printf

    mov  rcx, [rbp-16]
    inc  rcx
    jmp  .print_loop

.done:
    mov  rdi, [rbp-8]
    call free

    xor  eax, eax
    leave
    ret

.oom:
    lea  rdi, [msg_oom]
    xor  eax, eax
    call printf
    mov  edi, 1
    call exit

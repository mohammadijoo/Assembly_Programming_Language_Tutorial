; Chapter 7 - Lesson 4 - Example 1
; Working with heap via malloc/free: allocate int32 array, fill, sum, print.
; Build (Linux x86-64):
;   nasm -felf64 Chapter7_Lesson4_Ex1.asm -o ex1.o
;   gcc -no-pie ex1.o -o ex1
; Run:
;   ./ex1

default rel

global main
extern malloc
extern free
extern printf
extern exit

section .data
fmt_sum  db "sum = %ld", 10, 0
msg_oom  db "malloc failed", 10, 0

section .text
main:
    push rbp
    mov  rbp, rsp
    sub  rsp, 32            ; keep 16-byte alignment at call sites

    ; size = 10 * 4 bytes
    mov  edi, 40
    call malloc
    test rax, rax
    jz   .oom

    mov  [rbp-8], rax       ; save ptr
    xor  ecx, ecx           ; i = 0
    xor  r8, r8             ; sum = 0 (64-bit)

.fill_loop:
    cmp  ecx, 10
    jge  .done_fill

    ; val = 3*i + 1
    mov  eax, ecx
    lea  eax, [eax*2 + eax + 1]

    mov  rdx, [rbp-8]
    mov  [rdx + rcx*4], eax

    add  r8, rax
    inc  ecx
    jmp  .fill_loop

.done_fill:
    lea  rdi, [fmt_sum]
    mov  rsi, r8
    xor  eax, eax
    call printf

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

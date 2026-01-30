; Chapter 7 - Lesson 4 - Example 5
; Using mmap/munmap directly (anonymous mapping).
; This demonstrates "heap-like" memory not managed by malloc.
; Build (Linux x86-64):
;   nasm -felf64 Chapter7_Lesson4_Ex5.asm -o ex5.o
;   gcc -no-pie ex5.o -o ex5

default rel

global main
extern mmap
extern munmap
extern printf
extern exit

%define PROT_READ   1
%define PROT_WRITE  2
%define MAP_PRIVATE 2
%define MAP_ANON    0x20

section .data
fmt_val db "mmap ptr=%p  qword[0]=0x%lx", 10, 0
msg_bad db "mmap failed", 10, 0

section .text
main:
    push rbp
    mov  rbp, rsp
    sub  rsp, 64

    ; mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANON, -1, 0)
    xor  edi, edi
    mov  esi, 4096
    mov  edx, PROT_READ | PROT_WRITE
    mov  ecx, MAP_PRIVATE | MAP_ANON
    mov  r8,  -1
    xor  r9d, r9d
    call mmap

    cmp  rax, -1
    je   .fail

    mov  [rbp-8], rax

    ; write a value into the mapping
    mov  rdx, [rbp-8]
    mov  rax, 0x1122334455667788
    mov  [rdx], rax

    lea  rdi, [fmt_val]
    mov  rsi, [rbp-8]
    mov  rdx, [rdx]
    xor  eax, eax
    call printf

    ; munmap(ptr, 4096)
    mov  rdi, [rbp-8]
    mov  esi, 4096
    call munmap

    xor  eax, eax
    leave
    ret

.fail:
    lea  rdi, [msg_bad]
    xor  eax, eax
    call printf
    mov  edi, 1
    call exit

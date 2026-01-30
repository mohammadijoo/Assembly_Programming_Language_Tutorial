; Chapter7_Lesson2_Ex5.asm
; Lesson 2 (Chapter 7): Stack Frames and Stack Operations
; Demo: Walking the frame-pointer chain (RBP-linked list) to print return addresses.
;
; Build (Linux x86-64):
;   nasm -f elf64 Chapter7_Lesson2_Ex5.asm -o ex5.o
;   gcc -no-pie ex5.o -o ex5
; Run:
;   ./ex5

default rel
extern printf
global main

section .rodata
fmt: db "frame rbp=%p  return=%p", 10, 0

section .text
walk_frames:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 24                ; keep alignment: after push rbx, rsp mod16 = 8, so subtract 24

    mov rbx, rdi               ; rdi = starting rbp

.loop:
    test rbx, rbx
    jz .done
    mov rax, [rbx+8]           ; saved return address

    lea rdi, [fmt]
    mov rsi, rbx
    mov rdx, rax
    xor eax, eax
    call printf

    mov rbx, [rbx]             ; previous frame
    jmp .loop

.done:
    add rsp, 24
    pop rbx
    leave
    ret

f3:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    mov rdi, rbp
    call walk_frames

    leave
    ret

f2:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    call f3
    leave
    ret

f1:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    call f2
    leave
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    call f1

    xor eax, eax
    leave
    ret

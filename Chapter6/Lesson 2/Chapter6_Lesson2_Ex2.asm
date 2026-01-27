; Chapter 6 - Lesson 2 - Example 2
; File: Chapter6_Lesson2_Ex2.asm
; Topic: CALL variants and RET imm16 (pedagogical)
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson2_Ex2.asm -o ex2.o
;   ld -o ex2 ex2.o
; Run:
;   ./ex2 ; exits with status 0 on success

default rel

section .text
global _start

; --- Regular procedures (SysV-style return in RAX) ---

add1:
    ; RDI = x
    lea rax, [rdi + 1]
    ret

mul2:
    ; RDI = x
    lea rax, [rdi + rdi]
    ret

; --- A "stdcall-like" procedure using RET 8 to clean one 8-byte stack arg ---
; NOTE: SysV AMD64 does *not* use callee cleanup; this is only to demonstrate
; that the instruction exists and what it does.
stdcall_add3:
    ; Stack on entry:
    ;   [RSP + 0] = return address
    ;   [RSP + 8] = one qword argument (pushed by caller)
    mov rax, [rsp + 8]
    add rax, 3
    ret 8            ; pop return address, then add 8 to RSP (discard the arg)

_start:
    ; 1) Direct call
    mov rdi, 9
    call add1        ; RAX = 10

    ; 2) Indirect call via register
    mov rdi, rax     ; x = 10
    mov rbx, mul2    ; function pointer
    call rbx         ; RAX = 20

    ; 3) Demonstrate RET imm16 by pushing a stack argument
    push rax         ; push 20 as "argument"
    call stdcall_add3 ; RAX = 23 and callee cleans the pushed arg

    ; Validate expected result 23
    cmp rax, 23
    jne .fail

    ; exit(0)
    mov eax, 60
    xor edi, edi
    syscall

.fail:
    mov eax, 60
    mov edi, 1
    syscall

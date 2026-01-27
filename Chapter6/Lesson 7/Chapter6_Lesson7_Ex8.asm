; Chapter 6 - Lesson 7 - Exercise 1 (Solution)
; Title: Save an odd number of registers and still keep 16-byte call-site alignment
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson7_Ex8.asm -o ex8.o
;   ld -o ex8 ex8.o
;
; Goal:
;   - Save RBX, R12, R13 (3 pushes) and call a function.
;   - Ensure RSP % 16 == 0 at the call-site.

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .text

_start:
    call odd_save_and_call
    mov eax, 60
    xor edi, edi
    syscall

odd_save_and_call:
    ; Entry after CALL: rsp %16 == 8
    push rbp
    mov rbp, rsp

    ; Save callee-saved registers (odd count: 3 pushes => flips alignment)
    push rbx
    push r12
    push r13

    ; At this point, compute alignment:
    ;   entry: 8
    ;   push rbp => 0
    ;   push rbx => 8
    ;   push r12 => 0
    ;   push r13 => 8   (BAD for call-site)
    ;
    ; Fix: subtract 8 bytes padding so rsp becomes 0 mod 16.
    sub rsp, 8

    call callee_work

    add rsp, 8
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

callee_work:
    ; A tiny leaf
    xor eax, eax
    ret

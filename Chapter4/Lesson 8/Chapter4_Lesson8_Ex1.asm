BITS 64
default rel
global _start

; Chapter 4 - Lesson 8 (INC/DEC, NEG, ADC/SBB)
; Ex1: Capture RFLAGS after INC/DEC vs ADD/SUB.
; Inspect the stored qwords in a debugger (e.g., GDB) to see which flags changed.

section .data
    rflags_after_inc dq 0
    rflags_after_add dq 0
    rflags_after_dec dq 0
    rflags_after_sub dq 0

section .text
_start:
    ; INC preserves CF, but updates OF/SF/ZF/AF/PF.
    mov rax, -1                 ; 0xFFFF...FFFF
    stc                         ; CF = 1 (we want to see if it survives)
    inc rax                     ; rax = 0
    pushfq
    pop qword [rflags_after_inc]

    ; ADD updates CF as normal arithmetic carry.
    mov rbx, -1
    stc                         ; will be overwritten by ADD
    add rbx, 1                  ; rbx = 0, CF becomes 1 due to carry-out
    pushfq
    pop qword [rflags_after_add]

    ; DEC preserves CF as well.
    mov rcx, 0
    stc
    dec rcx                     ; rcx = -1
    pushfq
    pop qword [rflags_after_dec]

    ; SUB updates CF as borrow flag (CF=1 means borrow occurred).
    mov rdx, 0
    stc                         ; will be overwritten by SUB
    sub rdx, 1                  ; rdx = -1, CF=1 (borrow)
    pushfq
    pop qword [rflags_after_sub]

    ; Exit(0)
    mov eax, 60                 ; SYS_exit
    xor edi, edi
    syscall

; Chapter 6 - Lesson 8 (Exercise 2 Solution)
; Very hard: A small harness that checks ALL SysV AMD64 callee-saved GPRs for a target function.
; Callee-saved (SysV AMD64): RBX, RBP, R12, R13, R14, R15.
; Build (Linux x86-64):
;   nasm -felf64 Chapter6_Lesson8_Ex11.asm -o ex11.o
;   ld -o ex11 ex11.o
;   ./ex11

BITS 64
default rel
global _start

section .rodata
msg_ok   db "OK: target preserved all SysV callee-saved GPRs", 10
len_ok   equ $-msg_ok
msg_bad  db "OK: detected callee-saved violation", 10
len_bad  equ $-msg_bad
msg_fail db "FAIL: harness error", 10
len_fail equ $-msg_fail

section .text
write_msg:
    mov eax, 1
    mov edi, 1
    syscall
    ret

target_good:
    ; Pretend this is a library function.
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8              ; align for nested call (even pushes? actually 6 pushes -> even, entry 16n+8 -> 16n+8 -48 = 16n -40 => mod16=8, so need 8)
    ; modify preserved regs internally
    mov rbx, 1
    mov rbp, 2
    mov r12, 3
    mov r13, 4
    mov r14, 5
    mov r15, 6
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret

target_bad:
    ; Violates ABI by clobbering R14.
    xor r14, r14
    ret

check_sysv_callee_saved:
    ; rdi = function pointer to test
    ; returns eax = 0 if preserved, 1 if violated
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8              ; align for indirect call

    mov rbx, 0x1111111122222222
    mov rbp, 0x3333333344444444
    mov r12, 0x5555555566666666
    mov r13, 0x7777777788888888
    mov r14, 0x99999999AAAAAAAA
    mov r15, 0xBBBBBBBBCCCCCCCC

    call rdi

    cmp rbx, 0x1111111122222222
    jne .viol
    cmp rbp, 0x3333333344444444
    jne .viol
    cmp r12, 0x5555555566666666
    jne .viol
    cmp r13, 0x7777777788888888
    jne .viol
    cmp r14, 0x99999999AAAAAAAA
    jne .viol
    cmp r15, 0xBBBBBBBBCCCCCCCC
    jne .viol

    xor eax, eax
    jmp .out
.viol:
    mov eax, 1
.out:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret

_start:
    lea rdi, [rel target_good]
    call check_sysv_callee_saved
    test eax, eax
    jne .fail
    lea rsi, [rel msg_ok]
    mov edx, len_ok
    call write_msg

    lea rdi, [rel target_bad]
    call check_sysv_callee_saved
    cmp eax, 1
    jne .fail
    lea rsi, [rel msg_bad]
    mov edx, len_bad
    call write_msg

    mov eax, 60
    xor edi, edi
    syscall

.fail:
    lea rsi, [rel msg_fail]
    mov edx, len_fail
    call write_msg
    mov eax, 60
    mov edi, 1
    syscall
